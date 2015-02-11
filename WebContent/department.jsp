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

<h2>New Department Form</h2>

<%

Connection conn = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
PreparedStatement ps4 = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;

String jdbc = request.getParameter("jdbc");
String success = request.getParameter("success");
String name = request.getParameter("name");
String abbr = request.getParameter("abbr");

try
{
	if (success != null && success.equals("true"))
	{
		%><h4>BEFORE</h4><%
		%><h3>Department <%=name%> (<%=abbr%>) successfully added</h3><%
		%><h4>AFTER</h4><%
	}
	if (jdbc != null && jdbc.equals("insert"))
	{
		Class.forName("org.postgresql.Driver");
		conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
		conn.setAutoCommit(false);
		
		ps1 = conn.prepareStatement("SELECT * FROM department WHERE name = '" + name + "'");
		ps2 = conn.prepareStatement ("SELECT * FROM department WHERE abbr = '" + abbr + "'");
		rs1 = ps1.executeQuery();
		rs2 = ps2.executeQuery();
		boolean rs1flag = rs1.next();
		boolean rs2flag = rs2.next();
		
		if (rs1flag == true || rs2flag == true)
		{
			%><h3>Data not inserted: please fix following errors</h3>
			<%
			if (rs1flag == true)
			{
				%><h4>- Department name <%=name%> already exists</h4><%
			}
			if (rs2flag == true)
			{
				%><h4>- Abbreviation <%=abbr%> already exists</h4><%
			}
		}
		else
		{
			ps3 = conn.prepareStatement("INSERT INTO department (name, abbr) VALUES ('" + name + "', '" + abbr + "')");
			ps3.executeUpdate();
			conn.commit();
			%>
			<form action="department.jsp">
			<input type="hidden" name="success" value="true">
			<input type="hidden" name="dept" value="<%=name%>">
			<input type="hidden" name="abbr" value="<%=abbr%>">
			</form>
			<%
			response.sendRedirect("department.jsp");
		}
	}

%>
<form action="department.jsp">
<label for="name">Department Name:</label>
<input type="text" name="name">
<label for="abbr">Abbreviation:</label>
<input type="text" name="abbr">
<input type="hidden" name="jdbc" value="insert">
<input type="submit">
</form>
<%
	}
	catch (SQLException e)
	{
		if (conn != null)
			conn.rollback();
		e.printStackTrace();
	}
	finally
	{
		if (ps1 != null)
			ps1.close();
		if (ps2 != null)
			ps2.close();
		if (ps3 != null)
			ps3.close();
		if (ps4 != null)
			ps4.close();
		if (rs1 != null)
			rs1.close();
		if (rs2 != null)
			rs2.close();
		if (rs3 != null)
			rs3.close();
		if (rs4 != null)
			rs4.close();
		
		if (conn != null)
		{
			conn.setAutoCommit(false);
			conn.close();
		}
	}
%>
</body>
</html>