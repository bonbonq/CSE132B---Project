<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Faculty Taught Form</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>


<!-- HTML body part -->
<body>

	<h2>Faculty Previous Taught Course Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="faculty_taught.jsp" method="POST">
		
		<div>
			Faculty Name: <input type="text" name="faculty_name" required>
			<br>
		</div>
		<p>
		
		<div>
			Course:
			<select name="department">
				<%
				ResultSet course_rs = null;
				if (course_rs.isBeforeFirst())
				{
					while(course_rs.next()){
						%>
						<option value=<%=course_rs.getString("iddepartment")%>><%=course_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
<!-- HTML Body End -->


</html>