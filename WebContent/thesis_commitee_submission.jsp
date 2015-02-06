<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Thesis Committee Submission</title>
</head>



<!-- HTML body part -->
<body>

	<h2>Thesis Committee Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="thesis_committee_submission.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Department or Non-Department:
			<br>
			<input type="radio" name="faculty_type" value="department" checked>Department</input><br>
			<input type="radio" name="faculty_type" value="nondepartment" >Non-Department</input>
		</div>
		<p>
		
		<div>
			Faculty Name:
			<select name="faculty">
				<option value="name1">Test Name 1</option>
				<option value="name2">Test Name 2</option>
			</select>
		</div>
		<p>

		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>