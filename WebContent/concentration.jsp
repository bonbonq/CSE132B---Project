<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
        <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
	Connection conn = null;
	PreparedStatement ps1 = null;
	PreparedStatement ps2 = null;
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	
	String todo = request.getParameter("todo");
	if (todo == null)
	{
%>
<form action="concentration.jsp" >
<label for="dept">Select Department:</label>
<select name="dept">
<%
	String name = null;
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	ps1 = conn.prepareStatement("SELECT name FROM department");
	rs1 = ps1.executeQuery();
	while (rs1.next())
	{
		name = rs1.getString("name");
		System.out.println(name);
	%> <option value=<%=name%>><%=name%></option><% 
	}
	%>
</select>
<input type="hidden" name="todo" value="degree">
<input type="submit">

</form>
<%} else if (todo.equals("degree"))
	{%>
<form>
<%
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	String depname = request.getParameter("dept");
	String degname = null;
	ps2 = conn.prepareStatement("SELECT degree.name FROM degree JOIN (department_degree JOIN department) WHERE department.name = " + depname);
	rs2 = ps2.executeQuery();%>
	<label for="degree">Select Degree:</label>

	<select><%
	while (rs2.next())
	{
		degname = rs2.getString("name");
	%> <option value=<%=degname%>><%=degname%></option><% 
	}
	%>

</select>
<input type="hidden" name="todo" value="courseno">
<input type="submit">
</form>
<%} else
	{ %>
<form>
<label for="conc">Name of New Concentration:</label>
<input type="text" name="conc">
<input type="submit">
</form>
<%
	String dep = request.getParameter("dep");
	String sql1 = "SELECT number FROM department JOIN (department_course JOIN (course_coursenumber JOIN coursenumber)";
	String sql2 = "SELECT abbr FROM department WHERE name = " + dep;
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	ps1 = conn.prepareStatement(sql1);
	rs1 = ps1.executeQuery();
	ps2 = conn.prepareStatement(sql2);
	rs2 = ps2.executeQuery();
	rs2.next();
	String depab = rs2.getString("abbr");
	String courseno = null;
	%><form><%
	while (rs1.next())
	{
		courseno = depab + " " + rs1.getString("idcourseno");
		%><input type="checkbox" name="courseno" value=<%=courseno%>><br><%
	}
	
%><input type="submit">
</form>
<%} %>
</body>
</html>