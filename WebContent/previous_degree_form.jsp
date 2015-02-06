<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Previous Degree Entry Form</title>
</head>


<!-- HTML body part -->
<body>

	<h2>Previous Degree Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="previous_degree_entry_form.jsp" method="POST">
		
		<div>
			School Name:
			<select name="school_name" required>
				<option value="school1">Test School 1</option>
				<option value="school2">Test School 2</option>
				<option value="other">Other</option>
			</select>
			<p>
			If Other, please enter school name:
			<br>
			<input type="text" name="other_school_name">
			<br>
		</div>
		<p>
		
		<div>
			Degree Name:
			<select name="degree_name" required>
				<option value="degree1">Test Degree 1</option>
				<option value="degree2">Test Degree 2</option>
				<option value="other">Other</option>
			</select>
			<p>
			If Other, please enter degree name:
			<br>
			<input type="text" name="other_degree_name">
			<br>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>