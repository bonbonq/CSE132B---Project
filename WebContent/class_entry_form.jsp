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

Connection conn = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
PreparedStatement ps4 = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;



try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	String todo = request.getParameter("todo");
	String jdbc = request.getParameter("jdbc");
	String title = request.getParameter("title");
	
	if (jdbc != null && jdbc.equals("addsection"))
	{
		ps1 = conn.prepareStatement("INSERT INTO class (title) VALUES ('" + title + "') RETURNING idclass");
		ps1.execute();
		rs1 = ps1.getResultSet();
		rs1.next();
		System.out.println("before1");
		int classid = rs1.getInt("idclass");
		System.out.println("after1");
	    String year = request.getParameter("year");
		String courseno = request.getParameter("courseno");
		String dept = request.getParameter("department");
		System.out.println(classid);
		System.out.println(year);
		System.out.println(courseno);
		System.out.println(dept);
		ps2 = conn.prepareStatement("SELECT department_course.idcourse FROM department, department_course, course_coursenumber, coursenumber" + 
				" WHERE department.name = '" + dept + "'" + 
				" AND department_course.iddepartment = department.iddepartment" + 
				" AND department_course.idcourse = course_coursenumber.idcourse" + 
				" AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber" + 
				" AND coursenumber.number = '" + courseno + "'");
		rs2 = ps2.executeQuery();
		rs2.next();
		System.out.println("before2");
		int courseid = rs2.getInt("idcourse");
		System.out.println("after2");
		String quarter = request.getParameter("quarter");
		System.out.println("quarter");
		ps3 = conn.prepareStatement("SELECT idquarter FROM quarter WHERE year = " + year + " AND season = '" + quarter + "'");
		rs3 = ps3.executeQuery();
		rs3.next();
		System.out.println("before3");
		int quarterid = rs3.getInt("idquarter");
		System.out.println("after3");
		ps4 = conn.prepareStatement("INSERT INTO quarter_course_class__instance (idquarter, idcourse, idclass) VALUES (" + quarterid + ", " + courseid + ", " + classid + ")");
		
		ps4.executeUpdate();
		
		conn.commit();
		%><input type="hidden" name="todo" value="section">
		<input type="hidden" name="dept" value="<%=dept%>">
		<input type="hidden" name="courseno" value="<%=courseno%>">
		<input type="hidden" name="sectionid" value="<%=classid%>"><%
		response.sendRedirect("class_entry_form.jsp");
	}
	
	else if (todo == null)
	{
		ps1 = conn.prepareStatement("SELECT name FROM department");
		rs1 = ps1.executeQuery();
		%><form action="class_entry_form.jsp">
		<label for="department">Department:</label>
		<select name="department"><%
		String name = null;
		while (rs1.next())
		{	
			name = rs1.getString("name");
			%> <option value="<%=name%>"><%=name%></option>
			<%
		}%></select><input type="hidden" name="todo" value="course">
		<input type="submit"></form>
		<%
	}
	
	else if (todo.equals("course"))
	{
		String dept = request.getParameter("department");
		%><h3>Department: <%=dept%></h3><%
		ps1 = conn.prepareStatement("SELECT coursenumber.number FROM department, department_course, course_coursenumber, coursenumber " +
		     " WHERE department.name = '" + dept + "'" +
		     " AND department.iddepartment = department_course.iddepartment " + 
		     " AND department_course.idcourse = course_coursenumber.idcourse " + 
		     " AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber ");
		rs1 = ps1.executeQuery();
		%><form action="class_entry_form.jsp">
		<label for="courseno">Course Number</label>
		<select name="courseno"><%

		while (rs1.next())
		{
			String num = rs1.getString("number");
			%>
			<option value="<%=num%>"><%=num%></option>
		<%
		}
		%></select><input type="submit">
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
		
		<input type="hidden" name="jdbc" value="addsection">
		<input type="hidden" name="department" value="<%=dept %>">
		
		</form>
		<%
	}
	else if (todo.equals("section"))
	{
		String dept = request.getParameter("dept");
		String courseno = request.getParameter("courseno");
		String classid = request.getParameter("classid");
		%>
		<h3>Department: <%=dept%></h3>
		<h4>Course Number: <%=courseno%></h4>
		<h4>Section <%=classid%> successfully added</h4>
		
		<form action="section.jsp">
			<input type="hidden" name="todo" value="lecture">
			<input type="submit" value="Add Lecture">
		</form>
		
		<form action="section.jsp">
			<input type="hidden" name="todo" value="discussion">
			<input type="submit" value="Add Discussion">
		</form>
		
		<form action="section.jsp">
			<input type="hidden" name="todo" value="review">
			<input type="submit" value="Add Review Session">
		</form>
		
		<%
	}
}

catch (SQLException e)
{
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