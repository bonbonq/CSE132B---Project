<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
            <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Thesis Committee Submission</title>
</head>



<!-- HTML body part -->
<body>
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
String sql1 = null;
String sql2 = null;
String sql3 = null;
String sql4 = null;

try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	String action = request.getParameter("action");
	if (action != null && action.equals("view"))
	{
		sql4 = "SELECT * FROM faculty_graduate__dept";
		ps4 = conn.prepareStatement(sql4);
		rs4 = ps4.executeQuery();
		
		
		sql2 = "SELECT * FROM faculty_graduate__nondept";
		ps2 = conn.prepareStatement(sql2);
		rs2 = ps2.executeQuery();
		
		int sid = -1;
		String fname;
		
		%>
		<h3>Departmental</h3>
		<table>
		<tr>
			<th>Student ID</th>
			<th>Faculty Member</th>
			</tr>
			<%while (rs4.next())
				{
				sid = rs4.getInt("idstudent");
				fname = rs4.getString("faculty_name");
				%>
			<tr>
			<td><%=sid%></td>
			<td><%=fname%></td>
			<td>
					<form action="thesis_commitee_submission.jsp" method="POST">
						<input type="hidden" name="action" value="delete">
						<input type="hidden" name="type" value="dept">
						<input type="hidden" name="pid" value="<%=sid%>">
						<input type="submit" value="Delete">
					</form>
				</td>
				<td>
					<form action="thesis_commitee_submission.jsp" method="POST">
						<input type="hidden" name="action" value="update">
						<input type="submit" value="Update">
					</form>
				</td>
			</tr>
			<%} %>
			
		</table>
		
		<h3>Non-Departmental</h3>
		<table>
		<tr>
			<th>Student ID</th>
			<th>Faculty Member</th>
			</tr>
			<%while (rs2.next())
				{
				sid = rs2.getInt("idcandidate");
				fname = rs2.getString("faculty_name");
				%>
			<tr>
			<td>sid</td>
			<td>fname</td>
			<td>
					<form action="thesis_commitee_submission.jsp" method="POST">
						<input type="hidden" name="action" value="delete">
						<input type="hidden" name="type" value="ndept">
						<input type="hidden" name="pid" value="<%=sid%>">
						<input type="submit" value="Delete">
					</form>
				</td>
				<td>
					<form action="thesis_commitee_submission.jsp" method="POST">
						<input type="hidden" name="action" value="update">
						<input type="submit" value="Update">
					</form>
				</td>
			</tr>
			<%} %>
		</table>
		<%
	}
	else if (action != null && action.equals("delete"))
	{
		String type = request.getParameter("type");
		String pid = request.getParameter("pid");
		if (type.equals("dept"))
			sql4 = "DELETE FROM faculty_graduate__dept WHERE idstudent = ?";
		else
			sql4 = "DELETE FROM faculty_graduate__ndept WHERE idcandidate = ?";
		ps4 = conn.prepareStatement(sql4);
		ps4.setInt(1, Integer.parseInt(pid));
		ps4.executeUpdate();
		conn.commit();
		response.sendRedirect("thesis_commitee_submission.jsp?action=view");
	}
	
	else if (action != null && (action.equals("insert") || action.equals("update")))
	{
		String pid = request.getParameter("pid");
		sql3 = "SELECT idstudent FROM student WHERE idstudent = ?";
		ps3 = conn.prepareStatement(sql3);
		ps3.setInt(1, Integer.parseInt(pid));
		rs3 = ps3.executeQuery();
		if (!(rs3.next()))
		{
			%>
			<h2>Error: Student PID <%=pid%> does not exist</h2>
			<%
		}
		else
		{
			String faculty = request.getParameter("faculty");
			String deptTrue = request.getParameter("faculty_type");
			
			if (deptTrue.equals("department"))
				sql2 = "INSERT INTO faculty_graduate__dept (faculty_name, idstudent) VALUES (?, ?)";
			else
				sql2 = "INSERT INTO faculty_graduate__nondept (faculty_name, idstudent) VALUES (?, ?)";
			ps2 = conn.prepareStatement(sql2);
			ps2.setString(1, faculty);
			ps2.setInt(2, Integer.parseInt(pid));
			ps2.executeUpdate();
			conn.commit();
			%><h2>Successfully added faculty member <%=faculty%> to thesis committee for <%=pid%></h2><%
		}
	}
	
	%>
	<h2>Thesis Committee Submission Form</h2>
	<form action="thesis_commitee_submission.jsp" method="POST">
		<label for="pid">Student PID:</label>
		<input type="text" name="pid">
		Department or Non-Department:
			<input type="radio" name="faculty_type" value="department" checked>Department<br>
			<input type="radio" name="faculty_type" value="nondepartment" >Non-Department
		Faculty Member:
		<select name="faculty">
		<% 
			sql1 = "SELECT faculty_name FROM faculty";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			String fname;
		
			while (rs1.next())
			{
				fname = rs1.getString("faculty_name");
			%>
			<option><%=fname%></option>
			<%} %>
		</select>
		<input type="hidden" name="action" value="insert">
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