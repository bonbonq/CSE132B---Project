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
String sql1 = null;
String sql2 = null;
String sql3 = null;
String sql4 = null;


%>
<h2>Faculty Entry Form</h2>
<%
	try
	{
		Class.forName("org.postgresql.Driver");
		conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
		conn.setAutoCommit(false);
		
		String action = request.getParameter("action");
		if (action != null && action.equals("view"))
		{
			sql1 = "SELECT faculty.faculty_name, title, name FROM faculty, department_faculty, department" + 
		     	" WHERE faculty.faculty_name = department_faculty.faculty_name" + 
			 	" AND department_faculty.iddepartment = department.iddepartment";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			String faculty, title, dept;
		%>
			<table>
			<tr>
				<th>Faculty Member</th>
				<th>Title</th>
				<th>Department</th>
			</tr>
			<% while (rs1.next()) 
			{
				faculty = rs1.getString("faculty_name");
				title = rs1.getString("title");
				dept = rs1.getString("name");
				%>
			<tr>
				<td><%=faculty%></td>
				<td><%=title%></td>
				<td><%=dept%></td>
				<td>
					<form action="faculty_entry_form.jsp" method="POST">
							<input type="hidden" name="action" value="delete">
							<input type="hidden" name="faculty" value="<%=faculty%>">
							<input type="submit" value="Delete">
					</form>
				</td>
					<td>
					<form action="faculty_entry_form.jsp" method="POST">
						<input type="hidden" name="action" value="updatepre">
						<input type="hidden" name="faculty" value="<%=faculty%>">
						<input type="submit" value="Update">
					</form>
				</td>	
			</tr>
			</table><%
		}
		}
		else if (action != null && action.equals("delete"))
		{
			String faculty = request.getParameter("faculty");
			sql1 = "DELETE FROM faculty WHERE faculty_name = ?";
			ps1 = conn.prepareStatement(sql1);
			ps1.setString(1, faculty);
			ps1.executeUpdate();
			conn.commit();
			response.sendRedirect("faculty_entry_form.jsp?action=view");
		}
		else if (action != null && action.equals("update"))
		{
			String title = request.getParameter("title");
			System.out.println(title);
			String faculty = request.getParameter("faculty");
			System.out.println(faculty);
			String department = request.getParameter("department");
			sql1 = "UPDATE faculty SET title = ? WHERE faculty_name = ?";
			ps1 = conn.prepareStatement(sql1);
			ps1.setString(1, title);
			ps1.setString(2, faculty);
			ps1.executeUpdate();
			
			ps2 = conn.prepareStatement("SELECT iddepartment FROM department WHERE name = '" + department + "'");
			rs2 = ps2.executeQuery();
			rs2.next();
			int iddept = rs2.getInt("iddepartment");
			sql3 = "UPDATE department_faculty SET iddepartment = ?";
			ps3 = conn.prepareStatement(sql3);
			ps3.setInt(1, iddept);
			ps3.executeUpdate();
			conn.commit();
			
			response.sendRedirect("faculty_entry_form.jsp?action=view");
		}
		else if (action != null && action.equals("updatepre"))
		{
			String faculty = request.getParameter("faculty");
			%>
			<h2>Updating faculty member information for <%=faculty%></h2>
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
			<input type="hidden" name="action" value="update">
			<input type="hidden" name="faculty" value="<%=faculty%>">
<label for="title">Title: </label>
<input type="text" name="title">
<input type="submit">
</form>
			<%
			
		}
		else if (action != null && action.equals("insert"))
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
			%>
			<form action="faculty_entry_form.jsp" method="POST">
			<label for="department">Department:</label>
			<select name="department"><%
				ps4 = conn.prepareStatement("SELECT name FROM department");
				rs4 = ps4.executeQuery();
				String name2 = null;
				while (rs4.next())
				{	
					name2 = rs4.getString("name");
					%> <option value="<%=name2%>"><%=name2%></option>
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
		else
		{
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
		}}
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