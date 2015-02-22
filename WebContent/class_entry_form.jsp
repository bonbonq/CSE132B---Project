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
<a href="index.jsp"><button>Home</button></a>
<a href="class_entry_form.jsp"><button>Add Classes</button></a>
<a href="class_entry_form.jsp?action=view"><button>View All Classes</button></a>

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
	String title = request.getParameter("title");
	
	String action = request.getParameter("action");
	System.out.println("About to go in");
	System.out.println(action);
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
		<h2>Viewing All Classes</h2>
		<form action="class_entry_form.jsp" method="GET">
			<input type="submit" value="Add Classes">
		</form><br>
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
				<td>
					<form action="class_entry_form.jsp" method="POST">
						<input type="hidden" name="action" value="updatepre">
						<input type="hidden" name="idclass" value="<%=cid%>">
						<input type="hidden" name="department" value="<%=dep%>">
						<input type="submit" value="Update">
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
	
	else if (action != null && (action.equals("insert") || action.equals("update")))
	{
		int idclass;
		System.out.println(action);
		if (action.equals("insert"))
			sql1 = "INSERT INTO class (title) VALUES (?) RETURNING idclass";
		else
			sql1 = "UPDATE class SET title = ? WHERE idclass = ?";
		ps1 = conn.prepareStatement(sql1);
		ps1.setString(1, title);
		if (action.equals("update"))
		{
			idclass = Integer.parseInt(request.getParameter("idclass"));
			System.out.println(idclass);
			ps1.setInt(2, idclass);
			ps1.executeUpdate();
		}
		else
		{
			ps1.execute();
			rs1 = ps1.getResultSet();
			rs1.next();
			idclass = rs1.getInt("idclass");
			System.out.println("idclass:" + idclass);
		}

		String course = request.getParameter("idcourse");
		int idcourse = Integer.parseInt(course.split(",")[0]);
		course = course.split(",")[1];
		String quarter = request.getParameter("idquarter");
		int idquarter = Integer.parseInt(quarter.split(",")[0]);
		quarter = quarter.split(",")[1];
		if (action.equals("insert"))
			sql4 = "INSERT INTO quarter_course_class__instance (idquarter, idcourse, idclass) VALUES (?, ?, ?)";
		else
			sql4 = "UPDATE quarter_course_class__instance SET idquarter = ?, idcourse = ? WHERE idclass = ?";
		
		ps4 = conn.prepareStatement(sql4);
		ps4.setInt(1, idquarter);
		ps4.setInt(2, idcourse);
		ps4.setInt(3, idclass);
		ps4.executeUpdate();
		
		conn.commit();
		
		if (action.equals("insert"))
		{
			%>
			<h3>Class added successfully</h3>
			<%
		}
		else
		{
			%>
			<h3>Class information updated successfully</h3>
			<%
		}
		
		String dept = request.getParameter("department");
		
		%>
		<h3>Summary:</h3>
		<h3>Department: <%=dept%></h3>
		<h4>Course Number: <%=course%></h4>
		<h4>Quarter: <%=quarter%></h4>
		<h4>Class ID: <%=idclass%></h4>
		<h4>Class Title: <%=title%></h4>
		<form action="class_entry_form.jsp" method="POST">
			<input type="submit" value="Add Another Class">
		</form>
		<%
	}
	
	else if (action != null && (action.equals("create") || action.equals("updatepre")))
	{
		String dept = request.getParameter("department");
		String idclass = request.getParameter("idclass");
		%>
		<h3>Department: <%=dept%></h3>
		<br>
		<%
		if (action.equals("updatepre"))
		{
			%>
			<h4>Updating information for class <%=idclass%></h4>
			<%
		}
		sql1 = "SELECT course_coursenumber.idcourse, coursenumber.number FROM department, department_course, course_coursenumber, coursenumber " +
			     " WHERE department.name = ?" +
			     " AND department.iddepartment = department_course.iddepartment " + 
			     " AND department_course.idcourse = course_coursenumber.idcourse " + 
			     " AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber ";
		ps1 = conn.prepareStatement(sql1);
		ps1.setString(1, dept);
		rs1 = ps1.executeQuery();

		String season;
		int year, idquarter;
		sql2 = "SELECT * FROM quarter ORDER BY year";
		ps2 = conn.prepareStatement(sql2);
		rs2 = ps2.executeQuery();
		
		System.out.println("rs1:" + rs1.isBeforeFirst());
		System.out.println("rs2: " + rs1.isBeforeFirst());
		
		if (!(rs1.isBeforeFirst()) || !(rs2.isBeforeFirst()))
		{
			%><h3>Cannot Process Request</h3>
			<h4>Please fix errors noted below:</h4>
			<%
			if (!(rs1.isBeforeFirst()))
			{
			%>
			<h3>Department currently not offering any courses</h3>
			<form action="course_entry_form.jsp" method="POST">
				<input type="submit" value="Add Courses">
			</form>
			<form action="class_entry_form.jsp" method="POST">
				<input type="submit" value="Select Another Department">
			</form>
			<%
			}
			if (!(rs2.isBeforeFirst()))
			{
				%>
				<h3>No quarters found in database</h3>
				<form action="quarter_entry_form.jsp" method="POST">
					<input type="submit" value="Add Quarters">
				</form>
				<%
			}
		}
		else
		{
			%>
			<form>
				<label for="idcourse">Course Number:</label>
				<select name="idcourse">
			<%
		
			int idcourse;
			String num;
			String quarterString;
			while (rs1.next())
			{
				idcourse = rs1.getInt("idcourse");
				num = rs1.getString("number");
				%>
					<option value="<%=idcourse%>,<%=num%>"><%=num%></option>
				<%
			}
			%>
				</select>
				<br><br>
				
				<label for="title">Course Title:</label>
				<input type="text" name="title">
				<br><br>
				<label for="idquarter">Quarter:</label>
				<select name="idquarter">
			<%
			
			while (rs2.next())
			{
				idquarter = rs2.getInt("idquarter");
				season = rs2.getString("season");
				year = rs2.getInt("year");
				quarterString = season + " " + year;
			%>
					<option value="<%=idquarter%>,<%=quarterString%>"><%=season%> <%=year%></option>
			<% 
			}
			%>
				</select>
				<br><br>
			<%
			
			String myaction;
			if (!(action.equals("updatepre")))
				myaction = "insert";
			else
			{
				myaction = "update";
				%>
				<input type="hidden" name="idclass" value="<%=idclass%>">
				<%
			}
	
			   	%>
			   	<input type="hidden" name="action" value="<%=myaction%>">
			   	<input type="hidden" name="department" value="<%=dept %>">
			   	<input type="submit">
		</form>
		<form action="class_entry_form.jsp">
			<input type="submit" value="Select Different Department">
		</form>
		<%
		}
	}
	else
	{
		ps1 = conn.prepareStatement("SELECT name FROM department");
		rs1 = ps1.executeQuery();
		if (!(rs1.isBeforeFirst()))
		{
			%>
			<h3>Error: Cannot Process request</h3>
			<h4>No departments exist</h4>
			<a href="department.jsp"><button>Add Departments</button></a>
			<%
		}
		else
		{
		%>
			<form action="class_entry_form.jsp" method="GET"><br>
		
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