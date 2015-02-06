<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Past Class Taken</title>
</head>



<!-- HTML body part -->
<body>

	<h2>Classes taken in the Past</h2>
	
	<!-- Past Class Taken Insertion Form -->
	<form action="past_class_taken.jsp" method="POST">
		
		<div>
			Student Id: 
			<br>
			<input type="number" name="student_id" required>
		</div>
		<p>
		
		<div>
			Course Number: (ex. CSE132B) 
			<br>
			<input type="text" name="course_number" required>
		</div>
		<p>
		
		<div>
			Quarter Taken During: 
			<br>
			<input type="radio" name="quarter" value="fall">Fall<br>
			<input type="radio" name="quarter" value="winter">Winter<br>
			<input type="radio" name="quarter" value="spring">Spring<br>
			<input type="radio" name="quarter" value="summer">Summer<br>
			<br>
			Year: <input type="number" name="year" required>
		</div>
		<p>
		
		<div>
			Course Section: (This is only if the course has multiple sections)
			<br>
			<input type="text" name="course_section">
		</div>
		<p>
		
		<div>
			Grade: 
			<br>
			<input type="text" name="grade" required>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>