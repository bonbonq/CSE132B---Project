<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Degree Requirement Submission</title>
</head>
<body>
<h2>Degree Creation and Requirements</h2>
<form action="degree_requirement_info_submission.jsp">

<%
Connection conn = null;

try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	PreparedStatement ps1 = conn.prepareStatement("SELECT name FROM department");
	ResultSet rs1 = ps1.executeQuery();
	%>
	<label for="department">Department:</label>
	<select name="department"><%
	String name = null;
	while (rs1.next())
	{
		name = rs1.getString("name");
		%> <option value=<%=name%>><%=name%></option>
		<%
	}}
catch (SQLException e)
{
	e.printStackTrace();
}

finally
{
	if (conn != null)
		conn.close();
	
}%>
</select><br><br>
<label for="degree">Degree Name:</label>
<input type="text"><br><br>

<label for="total">Total Units:</label>
<input type="text" name="total"><br><br>
<label for="lowerdiv">Lower Division Units:</label>
<input type="text" name="lowerdiv"><br><br>
<label for="upperdiv">Upper Division Units:</label>
<input type="text" name="upperdiv"><br><br>
<label for="gpa">Minimum GPA:</label>
<input type="text" name="gpa"><br><br>


<input type="submit">
</form>
</body>
</html>