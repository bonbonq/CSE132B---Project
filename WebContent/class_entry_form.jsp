<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
        <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Class Entry Form</title>
</head>
<body>
<h2>Class Entry Form</h2>

<% 

session.invalidate();
session = request.getSession();

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
	String title = request.getParameter("title");
	
	String action = request.getParameter("action");
	if (action != null && action.equals("view"))
	{
		sql1 = "SELECT class.idclass, number, title, name, season, year FROM department, class, quarter_course_class__instance, course_coursenumber, quarter, department_course, coursenumber" + 
				" WHERE class.idclass = quarter_course_class__instance.idclass" +
				" AND department.iddepartment = department_course.iddepartment" +
				" AND department_course.idcourse = course_coursenumber.idcourse" +
				" AND quarter_course_class__instance.idquarter = quarter.idquarter" +
				" AND quarter_course_class__instance.idcourse = course_coursenumber.idcourse" +
				" AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber";
		ps1 = conn.prepareStatement(sql1);
		rs1 = ps1.executeQuery();
		%>
		<table>
			<tr>
				<th>Class ID</th>
				<th>Course Number</th>
				<th>Course Title</th>
				<th>Department</th>
				<th>Quarter</th>
				<th>Year</th>
			</tr>
		<%
		int cid;
		String cno, ct, dep, q, y;
		while (rs1.next())
		{
			cid = rs1.getInt(1);
			cno = rs1.getString(2);
			ct = rs1.getString(3);
			dep = rs1.getString(4);
			q = rs1.getString(5);
			y = rs1.getString(6);
		%>
			
			<tr>
				<td><%=cid%></td>
				<td><%=cno%></td>
				<td><%=ct%></td>
				<td><%=dep%></td>
				<td><%=q%></td>
				<td><%=y%></td>
				<td>
					<form action="class_entry_form.jsp" method="POST">
						<input type="hidden" name="action" value="delete">
						<input type="hidden" name="idclass" value="<%=cid%>">
						<input type="submit" value="Delete">
					</form>
				</td>
			</tr>
		<%
		} 
		%>
		</table>
		<%
		
	}
	else if (action != null && action.equals("delete"))
	{
	 	int idclass = Integer.parseInt(request.getParameter("idclass"));
		sql1 = "DELETE FROM class WHERE idclass = ?";
		ps1 = conn.prepareStatement(sql1);
		ps1.setInt(1, idclass);
		ps1.executeUpdate();
		conn.commit();
		response.sendRedirect("class_entry_form.jsp?action=view");
	}
	else if (action != null && (action.equals("insert")))
	{
		sql1 = "INSERT INTO class (title) VALUES (?) RETURNING idclass";
		ps1 = conn.prepareStatement(sql1);
		ps1.setString(1, title);
		ps1.execute();
		rs1 = ps1.getResultSet();
		rs1.next();
		int idclass = rs1.getInt("idclass");
	    int year = Integer.parseInt(request.getParameter("year"));
		String courseno = request.getParameter("courseno");
		String dept = request.getParameter("department");
		sql2 = "SELECT department_course.idcourse FROM department, department_course, course_coursenumber, coursenumber" + 
				" WHERE department.name = ?" + 
				" AND department_course.iddepartment = department.iddepartment" + 
				" AND department_course.idcourse = course_coursenumber.idcourse" + 
				" AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber" + 
				" AND coursenumber.number = ?";
		
		ps2 = conn.prepareStatement(sql2);
		ps2.setString(1, dept);
		ps2.setString(2, courseno);
		rs2 = ps2.executeQuery();
		rs2.next();
		int idcourse = rs2.getInt("idcourse");
		String quarter = request.getParameter("quarter");
		
		sql3 = "SELECT idquarter FROM quarter WHERE year = ? AND season = ?";
		ps3 = conn.prepareStatement(sql3);
		ps3.setInt(1, year);
		ps3.setString(2, quarter);
		rs3 = ps3.executeQuery();
		rs3.next();
		int idquarter = rs3.getInt("idquarter");
		
		sql4 = "INSERT INTO quarter_course_class__instance (idquarter, idcourse, idclass) VALUES (?, ?, ?)";
		ps4 = conn.prepareStatement(sql4);
		ps4.setInt(1, idquarter);
		ps4.setInt(2, idcourse);
		ps4.setInt(3, idclass);
		ps4.executeUpdate();
		conn.commit();
		session.setAttribute("dept", dept);
		session.setAttribute("quarter", quarter);
		session.setAttribute("year", year);
		session.setAttribute("courseno", courseno);
		session.setAttribute("idclass", idclass);
		session.setAttribute("idquarter", idquarter);
		session.setAttribute("idcourse", idcourse);
		session.setAttribute("sessionok", "okay");
		
		%>
		<h3>Class added successfully</h3>
		<h3>Summary:</h3>
		<h3>Department: <%=dept%></h3>
		<h4>Course Number: <%=courseno%></h4>
		<h4>Quarter: <%=quarter%></h4>
		<h4>Class ID: <%=idclass%></h4>
		<h4>Class Title: <%=title %></h4>
		
		<form action="section.jsp" method="POST">
			<input type="submit" value="Add Sections">
		</form>
		<form action="class_entry_form.jsp" method="POST">
			<input type="submit" value="Add Another Class">
		</form>
		<%
	}
	
	else if (action != null && action.equals("create"))
	{
		String dept = request.getParameter("department");
		%>
		<h3>Department: <%=dept%></h3>
		<%
		
		sql1 = "SELECT coursenumber.number FROM department, department_course, course_coursenumber, coursenumber " +
			     " WHERE department.name = ?" +
			     " AND department.iddepartment = department_course.iddepartment " + 
			     " AND department_course.idcourse = course_coursenumber.idcourse " + 
			     " AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber ";
		ps1 = conn.prepareStatement(sql1);
		ps1.setString(1, dept);
		rs1 = ps1.executeQuery();
		%>
		<form action="class_entry_form.jsp" method="POST">
			<label for="courseno">Course Number</label>
			<select name="courseno">
		<%
		while (rs1.next())
		{
			String num = rs1.getString("number");
			%>
				<option value="<%=num%>"><%=num%></option>
			<%
		}
		%>
			</select><input type="submit">
			<label for="title">Course Title:</label>
			<input type="text" name="title">
			<label for="quarter">Quarter:</label>
			<input type="radio" name="quarter" value="Fall">Fall
			<input type="radio" name="quarter" value="Winter">Winter
			<input type="radio" name="quarter" value="Spring">Spring
			<input type="radio" name="quarter" value="Summer">Summer
			<select name="year">
				<option value="2015">2015</option>
				<option value="2016">2016</option>
				<option value="2017">2017</option>
				<option value="2018">2018</option>
			</select>
		
			<input type="hidden" name="action" value="insert">
			<input type="hidden" name="department" value="<%=dept %>">	
		</form>
		<%
	}
	else
	{
		ps1 = conn.prepareStatement("SELECT name FROM department");
		rs1 = ps1.executeQuery();
		%>
		<form action="class_entry_form.jsp">
			<label for="department">Department:</label>
			<select name="department">
		<%
		
		String name = null;
		while (rs1.next())
		{	
			name = rs1.getString("name");
			%> 
				<option value="<%=name%>"><%=name%></option>
			<%
		}
		%>
			</select>
			<input type="hidden" name="action" value="create">
			<input type="submit">
		</form>
		<%
	}
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