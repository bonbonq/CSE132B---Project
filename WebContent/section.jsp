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
	
	session.removeAttribute("idsection");
	String sessionok = (String) session.getAttribute("sessionok");
	sessionok = "okay";
	if (sessionok == null || !(sessionok.equals("okay")))
	{
		%>
		<h2>ERROR: Session expired or no valid section chosen. Please return to home page and try again.</h2>
		<form action="index.jsp" method="POST">
			<input type="submit" value="Return to home page">
		</form>
		<%
	}
	String dept = (String) session.getAttribute("dept");
	String courseno = (String) session.getAttribute("courseno");
	String quarter = (String) session.getAttribute("quarter");
	Integer year = (Integer) session.getAttribute("year");
	Integer idclass = (Integer) session.getAttribute("idclass");
	%>
	<h2>Section Add Form</h2>
	<h3>Department:<%=dept%></h3>
	<h3>Class ID: <%=idclass%></h3>
	<h3>Course Number: <%=courseno%></h3>
	<h3>Quarter: <%=quarter%></h3>
	<h3>Year: <%=year%></h3>
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
			sql1 = "SELECT section.idsection, enrollment_limit, faculty_class_section.faculty_name, class.idclass, number, class.title, name, season, year " + 
					" FROM section, faculty, department, class, quarter_course_class__instance, course_coursenumber, quarter, department_course, coursenumber, faculty_class_section" + 
					" WHERE class.idclass = quarter_course_class__instance.idclass" +
					" AND section.idsection = faculty_class_section.idsection" + 
					" AND faculty_class_section.idclass = quarter_course_class__instance.idclass" + 
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
					<th>Section ID</th>
					<th>Class ID</th>
					<th>Course Number</th>
					<th>Course Title</th>
					<th>Department</th>
					<th>Instructor</th>
					<th>Enrollment Limit</th>
					<th>Quarter</th>
					<th>Year</th>
				</tr>
			<%
			int sid, cid, el;
			String cno, ct, dep, q, y, i;
			while (rs1.next())
			{
				sid = rs1.getInt("idsection");
				cid = rs1.getInt("idclass");
				cno = rs1.getString("number");
				ct = rs1.getString("title");
				dep = rs1.getString("name");
				q = rs1.getString("season");
				y = rs1.getString("year");
				el = rs1.getInt("enrollment_limit");
				i = rs1.getString("faculty_name");
			%>
				
				<tr>
					<td><%=sid%></td>
					<td><%=cid%></td>
					<td><%=cno%></td>
					<td><%=ct%></td>
					<td><%=dep%></td>
					<td><%=i%></td>
					<td><%=el%></td>
					<td><%=q%></td>
					<td><%=y%></td>
					<td>
						<form action="section.jsp" method="POST">
							<input type="hidden" name="action" value="delete">
							<input type="hidden" name="idsection" value="<%=sid%>">
							<input type="submit" value="Delete">
						</form>
					</td>
					<td>
					<form action="section.jsp" method="POST">
						<input type="hidden" name="action" value="updatepre">
						<input type="hidden" name="idsection" value="<%=sid%>">
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
			int idsection = Integer.parseInt(request.getParameter("idsection"));
			sql1 = "DELETE FROM section WHERE idsection = ?";
			ps1 = conn.prepareStatement(sql1);
			ps1.setInt(1, idsection);
			ps1.executeUpdate();
			conn.commit();
			response.sendRedirect("section.jsp?action=view");
		}
		else if (action != null && action.equals("insert"))
		{
			int enrollmentLimit = Integer.parseInt(request.getParameter("enrollment"));
			sql1 = "INSERT INTO section (enrollment_limit) VALUES (?) RETURNING idsection";
			ps1 = conn.prepareStatement(sql1);
			ps1.setInt(1, enrollmentLimit);
			ps1.execute();
			rs1 = ps1.getResultSet();
			rs1.next();
			int idsection = rs1.getInt("idsection");
			String faculty = request.getParameter("faculty");
			sql2 = "INSERT INTO faculty_class_section (faculty_name, idclass, idsection) VALUES (?, ?, ?)";
			ps2 = conn.prepareStatement(sql2);
			ps2.setString(1, faculty);
			ps2.setInt(2, idclass);
			ps2.setInt(3, idsection);
			ps2.executeUpdate();
			conn.commit();
			session.setAttribute("idsection", idsection);
			%>
			<h3>Successfully added section</h3>
			<h3>Summary:</h3>
			<h4>Department: <%=dept%></h4>
			<h4>Course Number: <%=courseno%></h4>
			<h4>Class ID: <%=idclass%></h4>
			<h4>Section ID: <%=idsection%></h4>
			<h4>Teaching Faculty: <%=faculty%></h4>
			<h4>Enrollment Limit: <%=enrollmentLimit%></h4>
			<form action="subsection.jsp" method="POST">
				<input type="submit" value="Add lecture/discussion/review">
			</form>
			<form action="section.jsp" method="POST">
				<input type="submit" value="Add a new section">
			</form>
			<form action="class_entry_form.jsp" method="POST">
				<input type="submit" value="Add a new class">
			</form>
			<%
		}
		else if (action != null && action.equals("update"))
		{
			int idsection = Integer.parseInt(request.getParameter("idsection"));
			int enrollmentLimit = Integer.parseInt(request.getParameter("enrollment"));
			sql1 = "UPDATE section SET enrollment_limit = ? WHERE idsection = ?";
			ps1 = conn.prepareStatement(sql1);
			ps1.setInt(1, enrollmentLimit);
			ps1.setInt(2, idsection);
			ps1.executeUpdate();
			
			String faculty = request.getParameter("faculty");
			sql2 = "UPDATE faculty_class_section SET faculty_name = ? WHERE idsection = ?";
			ps2 = conn.prepareStatement(sql2);
			ps2.setString(1, faculty);
			ps2.setInt(2, idsection);
			ps2.executeUpdate();
			conn.commit();
			response.sendRedirect("section.jsp?action=view");
		}
		
		else if (action != null && action.equals("updatepre"))
		{
			String idsection = request.getParameter("idsection");
			sql1 = "SELECT faculty_name FROM faculty";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			%>
			<form action="section.jsp" method="POST">
				<label for="faculty">Teaching Faculty:</label>
				<select name="faculty">
			<%
			String name = "";
			while (rs1.next())
			{
				name = rs1.getString("faculty_name");
					%><option value="<%=name%>"><%=name%></option><%
			}
			%>
				</select>
				<label for="enrollment">Enrollment Limit</label>
				<input type="text" name="enrollment">
				<input type="hidden" name="action" value="update">
				<input type="hidden" name="idsection" value="<%=idsection%>">
				<input type="submit">
			</form>
			<%
		}
		
		
		else
		{
			sql1 = "SELECT faculty_name FROM faculty";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			%>
			<form action="section.jsp" method="POST">
				<label for="faculty">Teaching Faculty:</label>
				<select name="faculty">
			<%
			String name = "";
			while (rs1.next())
			{
				name = rs1.getString("faculty_name");
					%><option value="<%=name%>"><%=name%></option><%
			}
			%>
				</select>
				<label for="enrollment">Enrollment Limit</label>
				<input type="text" name="enrollment">
				<input type="hidden" name="action" value="insert">
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