<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
            <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Faculty Entry Form</title>
</head>
<body><% 
Connection conn = null;
PreparedStatement ps0 = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
PreparedStatement ps4 = null;
ResultSet rs0 = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;

%>
<h2>Faculty Entry Form</h2>
<%
	try
	{
		Class.forName("org.postgresql.Driver");
		conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
		conn.setAutoCommit(false);
		
		String action = request.getParameter("action");
		if (action != null && action.equals("insert"))
		{
			String name = request.getParameter("name");
			String title = request.getParameter("title");
			ps0 = conn.prepareStatement("SELECT faculty_name FROM faculty WHERE faculty_name = '" + name + "'");
			rs0 = ps0.executeQuery();
			boolean flag = rs0.next();
			if (flag == false)
			{
			String department = request.getParameter("department");
			ps1 = conn.prepareStatement("INSERT INTO faculty (faculty_name, title) VALUES ('" + name + "', '" + title + "')");
			ps1.executeUpdate();
			ps2 = conn.prepareStatement("SELECT iddepartment FROM department WHERE name = '" + department + "'");
			rs2 = ps2.executeQuery();
			rs2.next();
			int iddept = rs2.getInt("iddepartment");
			ps3 = conn.prepareStatement("INSERT INTO department_faculty (iddepartment, faculty_name) VALUES (" + iddept + ", '" + name + "')");
			ps3.executeUpdate();
			conn.commit();
			%><h2>Faculty member <%=name%> (<%=department%>) successfully submitted</h2><%
			}
			else
			{
				%><h2>ERROR: Faculty member "<%=name%>"already exists</h2><%
			}
		}
		%>
		<form action="faculty_entry_form.jsp" method="POST">
		<label for="department">Department:</label>
		<select name="department"><%
			ps4 = conn.prepareStatement("SELECT name FROM department");
			rs4 = ps4.executeQuery();
			String name = null;
			while (rs4.next())
			{	
				name = rs4.getString("name");
				%> <option value="<%=name%>"><%=name%></option>
				<%
			}%></select><input type="hidden" name="todo" value="course">
			<input type="hidden" name="action" value="insert">
			<label for="name">Name: </label>
<input type="text" name="name">
<label for="title">Title: </label>
<input type="text" name="title">
<input type="submit">
</form>
<%
		}
		catch (SQLException e)
		{
			conn.rollback();
			e.printStackTrace();
		}
		finally
		{
			if (ps0 != null)
				ps0.close();
			if (ps1 != null)
				ps1.close();
			if (ps2 != null)
				ps2.close();
			if (ps3 != null)
				ps3.close();
			if (ps4 != null)
				ps4.close();
			if (rs0 != null)
				rs0.close();
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
				conn.setAutoCommit(true);
				conn.close();
			}
		}


%>
</body>
</html>