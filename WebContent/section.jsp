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
<h2>Class Entry Form</h2>
<a href="index.jsp"><button>Home</button></a>
<a href="section.jsp"><button>Add Sections</button></a>
<a href="section.jsp?action=view"><button>View All Sections</button></a>
<%


	%>
	<h2>Section Add Form</h2>
	<%
	
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
	String sql0 = null;
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
			
			String success = (String) session.getAttribute("success");
			Integer idsection_view = (Integer) session.getAttribute("idsection");
			
			//flag 1
			if (success != null)
			{
				%>
				<h3><%=success%> of section ID <%=idsection_view%> was successful!</h3>
				<%
			}
			
			session.removeAttribute("success");
			session.removeAttribute("idsection");
			
			sql1 = "SELECT faculty_class_section.idsection, enrollment_limit, faculty_class_section.faculty_name, class.idclass, class.title, season, year " + 
					" FROM section, class, quarter_course_class__instance, quarter, faculty_class_section" + 
					" WHERE class.idclass = quarter_course_class__instance.idclass" +
					" AND faculty_class_section.idclass = quarter_course_class__instance.idclass" + 
					" AND quarter_course_class__instance.idquarter = quarter.idquarter" +
					" AND section.idsection = faculty_class_section.idsection";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			%>
			<table>
				<tr>
					<th>Section ID</th>
					<th>Class ID</th>
					<th>Course Number</th>
					<th>Course Title</th>
					<th>Instructor</th>
					<th>Enrollment Limit</th>
					<th>Quarter</th>
					<th>Year</th>
				</tr>
			<%
			int sid, cid, el;
			String cno, ct, i, q, y;
			while (rs1.next())
			{
				sid = rs1.getInt("idsection");
				cid = rs1.getInt("idclass");
				sql2 = "SELECT number FROM quarter_course_class__instance, course_coursenumber, coursenumber" +
				           " WHERE course_coursenumber.idcoursenumber = coursenumber.idcoursenumber" + 
				           " AND quarter_course_class__instance.idclass = ?" + 
				           " AND quarter_course_class__instance.idcourse = course_coursenumber.idcourse";
				ps2 = conn.prepareStatement(sql2);
				ps2.setInt(1, cid);
				rs2 = ps2.executeQuery();
				rs2.next();
				cno = rs2.getString("number");
				while (rs2.next())
				{
					cno += "/";
					cno += rs2.getString("number");
				}
				
				ps2.close();
				rs2.close();
				
				ct = rs1.getString("title");
				i = rs1.getString("faculty_name");
				el = rs1.getInt("enrollment_limit");
				q = rs1.getString("season");
				y = rs1.getString("year");
				
				
			%>
				
				<tr>
					<td><%=sid%></td>
					<td><%=cid%></td>
					<td><%=cno%></td>
					<td><%=ct%></td>
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
			session.setAttribute("success", "Delete");
			session.setAttribute("idsection", idsection);
			response.sendRedirect("section.jsp?action=view");
		}
		else if (action != null && action.equals("insert"))
		{
			int enrollmentLimit = Integer.parseInt(request.getParameter("enrollment"));
			int idclass_insert = Integer.parseInt(request.getParameter("idclass"));
			int idinstance_insert = Integer.parseInt(request.getParameter("idinstance"));
			
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
			ps2.setInt(2, idclass_insert);
			ps2.setInt(3, idsection);
			ps2.executeUpdate();
			
			sql3 = "INSERT INTO instance_section (idinstance, idsection) VALUES (?, ?)";
			ps3 = conn.prepareStatement(sql3);
			ps3.setInt(1, idinstance_insert);
			ps3.setInt(2, idsection);
			ps3.executeUpdate();
			conn.commit();
			session.setAttribute("success", "Insert");
			session.setAttribute("idsection", idsection);
			response.sendRedirect("section.jsp?action=view");
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
			
			session.setAttribute("success", "Update");
			session.setAttribute("idsection", idsection);
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
		
		
		else if (action != null && action.equals("create"))
		{
			int idclass_create = Integer.parseInt(request.getParameter("idclass"));
		
			sql2 = "SELECT * FROM quarter_course_class__instance, class, quarter, course_coursenumber, coursenumber" +
			      " WHERE quarter.idquarter = quarter_course_class__instance.idquarter" + 
			      " AND quarter_course_class__instance.idclass = class.idclass" + 
			      " AND class.idclass = ?" +
			      " AND quarter_course_class__instance.idcourse = course_coursenumber.idcourse" +
			      " AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber";
			ps2 = conn.prepareStatement(sql2);
			ps2.setInt(1, idclass_create);
			rs2 = ps2.executeQuery();
			rs2.next();
			String quarter = rs2.getString("season") + " " + rs2.getString("year");
			String title = rs2.getString("title");
			String idcourse = rs2.getString("idcourse");
			String courseno = rs2.getString("number");
			while (rs2.next())
			{
				courseno += " / ";
				courseno += rs2.getString("number");
			}
		
			
			%>
			
			<h4>Course and Class Information</h4>
			<ul>
				<li>Course ID: <%=idcourse%></li>
				<li>Course Number(s): <%=courseno%></li>
				<li>Class ID: <%=idclass_create%></li>
				<li>Title: <%=title%></li>
				<li>Quarter: <%=quarter%></li>
			</ul>
			<%
			String name = "";
			sql1 = "SELECT faculty_name FROM faculty";
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			
			if (!(rs1.isBeforeFirst()))
			{
				%>
				<h3>Error: Cannot Process Request</h3>
				<h4>No Faculty Members Exist in Database</h4>
				<a href="faculty_entry_form.jsp"><button>Add Faculty Members</button></a>
				
				<%
			}
			else
			{
			%>
			<form action="section.jsp" method="POST">
				<label for="faculty">Teaching Faculty:</label>
				<select name="faculty">
			<%
			while (rs1.next())
			{
				name = rs1.getString("faculty_name");
					%><option value="<%=name%>"><%=name%></option><%
			}
			%>
			</select>
			<%
			sql3 = "SELECT idinstance FROM quarter_course_class__instance WHERE idclass = ?";
			ps3 = conn.prepareStatement(sql3);
			ps3.setInt(1, idclass_create);
			rs3 = ps3.executeQuery();
			rs3.next();
			int idinstance_create = rs3.getInt("idinstance");
			%>
				
				<label for="enrollment">Enrollment Limit</label>
				<input type="text" name="enrollment">
				<input type="hidden" name="action" value="insert">
				<input type="hidden" name="idclass" value="<%=idclass_create%>">
				<input type="hidden" name="idinstance" value="<%=idinstance_create%>">
				<input type="hidden" name="quarter" value="<%=quarter%>">
				<input type="hidden" name="idcourse" value="<%=idcourse%>">
				<input type="hidden" name="courseno" value="<%=courseno%>">
				<input type="hidden" name="title" value="<%=title%>">
				
				<input type="submit">
			</form>
			<%
		}
		}
		else
		{
			sql0 = "SELECT * FROM class NATURAL JOIN quarter_course_class__instance NATURAL JOIN quarter"; 
			ps0 = conn.prepareStatement(sql0);
			rs0 = ps0.executeQuery();
			
			if (!(rs0.isBeforeFirst()))
			{
				%>
				<h3>Cannot process request: No classes in database</h3>
				<a href="class_entry_form.jsp"><button>Add Classes</button></a>
				<%
			}
			else
			{
				%>
				<form action="section.jsp" method="GET">
				<select name="idclass"><%
				int idclass;
				String title;
				while (rs0.next())
				{
					idclass = rs0.getInt("idclass");
					title = rs0.getString("title");
					%>
						<option value="<%=idclass%>"><%=idclass%> - <%=title%> - <%=rs0.getString("season")%> <%=rs0.getString("year") %></option>
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