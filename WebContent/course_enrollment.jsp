<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Course Enrollment</title>
</head>



<!-- HTML Body Start -->
<body>

	<h2>Course Enrollment Form</h2>

	<!-- Insertion Form -->
	<form action="course_enrollment.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Course number:
			<select name="course_number" required>
				<option value="course1">Test Course 1</option>
				<option value="course2">Test Course 2</option>
			</select>
		</div>	
		<p>
		
		<div>
			If multiple sections in course:
			<br>
			Section Number: <input type="text" name="section_number">
			<br>
		</div>
		<p>
		
		<div>
			<br>
			Units: <input type="number" name="units" required>
			<br>
		</div>
		<p>
		
		<div>
			Grade Type:
			<br>
			<input type="radio" name="grade_type" value="letter" checked>Letter</input><br>
			<input type="radio" name="grade_type" value="su" >S/U</input>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>


</body>
<!-- HTML Body End -->
</html>