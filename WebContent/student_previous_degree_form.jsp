<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student's Previous Degree Entry Form</title>
</head>



<!-- HTML body part -->
<body>

	<h2>Student's Previous Earned Degree Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="student_previous_degree_form.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			School Name:
			<select name="school">
				<option value="school1">Test School 1</option>
				<option value="school2">Test School 2</option>
			</select>
		</div>
		<p>
		
		<div>
			Degree Name:
			<select name="degree">
				<option value="degree1">Test Degree 1</option>
				<option value="degree2">Test Degree 1</option>
			</select>
		</div>
		<p>

		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>