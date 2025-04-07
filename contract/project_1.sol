// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlockchainPoweredCourses {

    struct Course {
        string name;
        string description;
        uint price;
        address instructor;
        bool isActive;
    }

    struct Enrollment {
        address student;
        uint courseId;
        bool isEnrolled;
    }

    mapping(uint => Course) public courses;
    mapping(address => Enrollment[]) public studentEnrollments;

    uint public courseCount = 0;

    event CourseCreated(uint courseId, string name, uint price, address instructor);
    event CoursePurchased(address student, uint courseId);
    event CourseStatusUpdated(uint courseId, bool isActive);

    modifier onlyInstructor(uint courseId) {
        require(courses[courseId].instructor == msg.sender, "You are not the instructor");
        _;
    }

    modifier courseExists(uint courseId) {
        require(courseId < courseCount, "Course does not exist");
        _;
    }

    function createCourse(string memory _name, string memory _description, uint _price) public {
        courseCount++;
        courses[courseCount] = Course({
            name: _name,
            description: _description,
            price: _price,
            instructor: msg.sender,
            isActive: true
        });

        emit CourseCreated(courseCount, _name, _price, msg.sender);
    }

    function purchaseCourse(uint _courseId) public payable courseExists(_courseId) {
        Course memory course = courses[_courseId];
        require(course.isActive, "Course is not active");
        require(msg.value == course.price, "Incorrect payment amount");

        studentEnrollments[msg.sender].push(Enrollment({
            student: msg.sender,
            courseId: _courseId,
            isEnrolled: true
        }));

        payable(course.instructor).transfer(msg.value);
        emit CoursePurchased(msg.sender, _courseId);
    }

    function updateCourseStatus(uint _courseId, bool _status) public onlyInstructor(_courseId) {
        courses[_courseId].isActive = _status;
        emit CourseStatusUpdated(_courseId, _status);
    }

    function getStudentEnrollments(address _student) public view returns (Enrollment[] memory) {
        return studentEnrollments[_student];
    }

    function getCourseDetails(uint _courseId) public view courseExists(_courseId) returns (string memory name, string memory description, uint price, address instructor, bool isActive) {
        Course memory course = courses[_courseId];
        return (course.name, course.description, course.price, course.instructor, course.isActive);
    }
}
