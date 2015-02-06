<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Graduate Entry Form</title>
</head>


<!--
PhD students are further classified into PhD candidates and pre-candidacy students. All candidates are required to have an advisor and a thesis committee, which is described below.    
-->
<!-- HTML body part -->
<body>

	<h2>Graduate Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="graduate_entry_form.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Type: 
			<br>
			<input type="radio" name="type" value="ms" checked>MS<br>
			<input type="radio" name="type" value="5year" >5 Year BS/MS<br>
			<input type="radio" name="type" value="precandidate" >Ph.D. (pre-candidacy)<br>
			<input type="radio" name="type" value="candidate" >Ph.D. (candidate)<br>
			<br>
		</div>
		<p>
		
		<div>
			Department:
			<select name="department">
				<option value="department1">Test Department 1</option>
				<option value="department2">Test Department 2</option>
			</select>
		</div>
		<p>
		
		<div>
			For Ph.D. candidates only:
			<br>
			Advisor: <input type="text" name="advisor">
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>