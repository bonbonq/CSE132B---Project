<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Entry Form</title>
</head>


<!--

A student has periods of attendance. For example, a student may have attended from Spring 1999-Winter 2000 and from Fall 2000-Spring 2001.
He may already hold some degrees (e.g., Bachelors) from UCSD or other universities.
-->

<!-- HTML body part -->
<body>

	<h2>Student Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="student_entry_form.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
			First Name: <input type="number" name="first_name" required>
			<br>
			Last Name: <input type="number" name="last_name" required>
			<br>
			Middle Name: <input type="number" name="middle_name">
			<br>
			Social Security Numbmer: <input type="number" name="social_security_number" required>
		</div>
		<p>
		
		<div>
			Course Number: (ex. CSE132B) 
			<br>
			<input type="text" name="course_number" required>
		</div>
		<p>
		
		<div>
			Enrolled? 
			<br>
			<input type="radio" name="enrollment" value="yes" checked>Yes<br>
			<input type="radio" name="enrollment" value="no">No<br>
			<br>
		</div>
		<p>
		
		<div>
			Residency: 
			<br>
			<input type="radio" name="residency" value="ca" checked>California Resident<br>
			<input type="radio" name="residency" value="nonca">Non-California Resident<br>
			<input type="radio" name="residency" value="foreign">Foreign Resident<br>
			<br>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>