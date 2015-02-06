<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Probation Information Form</title>
</head>

<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<%
	Connection conn = null;
	String action = request.getParameter("action");
	if (action != null && action.equals("insert"))
	{
		String id = request.getParameter("id");
		String quarter = request.getParameter("quarter");
		String reason = request.getParameter("reason");
		try
		{
			conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
			String sql = "INSERT INTO student_quarter__probation VALUES (" + id + ", " + quarter + ", " + reason + ")";
			//RESUME
		}
		
		catch (SQLException e)
		{
			e.printStackTrace();
		}
	}
%>
<body>
<h2>Probation Information Submission</h2>
<form action="probation_info_submission.jsp" method="post">
	<label for="id">Student ID</label>
	<input type="text" name="id"><br><br>
	<label for="quarter">Quarter<br></label>
	<input type="radio" name="quarter" value="fall">Fall<br>
	<input type="radio" name="quarter" value="winter">Winter<br>
	<input type="radio" name="quarter" value="spring">Spring<br>
	<input type="radio" name="quarter" value="summer">Summer<br><br>
	<label for="reason">Reason For Probation:<br></label>
<textarea rows="5" cols="50" id="reason"></textarea><br><br>
<input type="submit"><br>
</form>

</body>
</html>