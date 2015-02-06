<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Undergraduate Entry Form</title>
</head>



<!-- HTML body part -->
<body>

	<h2>Undergraduate Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="undergraduate_entry_form.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Major:
			<select name="major">
				<option value="major1">Test Major 1</option>
				<option value="major2">Test Major 2</option>
			</select>
		</div>
		<p>
		
		<div>
			Minor:
			<select name="minor">
				<option value="none">None</option>
				<option value="minor1">Test Major 1</option>
				<option value="minor2">Test Major 1</option>
			</select>
		</div>
		<p>

		<div>
			College: 
			<br>
			<input type="radio" name="college" value="revelle" checked>Revelle College<br>
			<input type="radio" name="college" value="muir" >Muir College<br>
			<input type="radio" name="college" value="marshall" >Marshall College<br>
			<input type="radio" name="college" value="warren" >Warren College<br>
			<input type="radio" name="college" value="erc" >Eleanor Roosevelt College<br>
			<input type="radio" name="college" value="sixth" >Sixth College<br>
			<br>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>