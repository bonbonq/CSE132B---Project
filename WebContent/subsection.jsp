<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
	
		String action = request.getParameter("action");
		
		%>
		<a href= "index.jsp"><button>Home</button></a>
		<a href="subsection.jsp"><button>Add Lecture, Discussion, Review Session</button></a>
		<a href="subsection.jsp?action=view"><button>View All Lectures, Discussions, Review Sessions</button></a>
		<h2>Sub-section Add Form</h2>
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
		
			if (action != null && action.equals("view"))
			{
				String success = (String) session.getAttribute("success");
				Integer idsection = (Integer) session.getAttribute("idsection");
				if (success != null && !(success.equals("")))
				{
					%>
					<h3><%=success%> Of Section <%=idsection%> Successful!</h3>
					<%
				}
				session.removeAttribute("success");
				session.removeAttribute("idsection");
				
				sql2 = "SELECT * FROM section_reviewsession, reviewsession WHERE reviewsession.idreviewsession = section_reviewsession.idreviewsession";
				ps2 = conn.prepareStatement(sql2);
				rs2 = ps2.executeQuery();
			
				sql1 = "SELECT * FROM section_weekly, weekly WHERE weekly.idweekly = section_weekly.idweekly";
				ps1 = conn.prepareStatement(sql1);
				rs1 = ps1.executeQuery();
			
				%>
				<h3>Lectures and Discussions</h3>
				<table>
					<tr>
						<th>Section ID</th>
						<th>Weekly ID</th>
						<th>Days of Week</th>
						<th>Start Time</th>
						<th>End Time</th>
						<th>Building</th>
						<th>Room Number</th>
						<th>Type</th>
					</tr>
				<%
				int sid, wid;
				String dow, b, rn, t;
				java.sql.Time st1, et1, st2, et2;
				java.sql.Date d;
				while (rs1.next())
				{
					sid = rs1.getInt("idsection");
					wid = rs1.getInt("idweekly");
					dow = rs1.getString("day_of_week");
					st1 = rs1.getTime("start_time");
					et1 = rs1.getTime("end_time");
					b = rs1.getString("building");
					rn = rs1.getString("room");
					t = rs1.getString("type");
				%> 
					<tr>
						<td><%=sid%></td>
						<td><%=wid%></td>
						<td><%=dow%></td>
						<td><%=st1%></td>
						<td><%=et1%></td>
						<td><%=b%></td>
						<td><%=rn%></td>
						<td><%=t%></td>
						<td>
							<form action="subsection.jsp" method="POST">
								<input type="hidden" name="action" value="delete">
								<input type="hidden" name="id" value="<%=wid%>">
								<input type="hidden" name="type" value="weekly">
								<input type="submit" value="Delete">
							</form>
						</td>
						<td>
							<form action="subsection.jsp" method="POST">
							<input type="hidden" name="action" value="updatepre">
							<input type="hidden" name="idsection" value="<%=sid%>">
							<input type="hidden" name="type" value="<%=t%>">
							<input type="hidden" name="idweekly" value="<%=wid%>">
							<input type="submit" value="Update">
							</form>
						</td>
					
					</tr>
				<%
				} 
				%>
				</table>
				<h3>Review Sessions</h3>
				<table>
					<tr>
						<th>Section ID</th>
						<th>Review ID</th>
						<th>Date</th>
						<th>Start Time</th>
						<th>End Time</th>
						<th>Building</th>
						<th>Room Number</th>
						<th>Type</th>
					</tr>
				<%
				while (rs2.next())
				{
					sid = rs2.getInt("idsection");
					wid = rs2.getInt("idreviewsession");
					d = rs2.getDate("time");
					st2 = rs2.getTime("start_time");
					et2 = rs2.getTime("end_time");
					b = rs2.getString("building");
					rn = rs2.getString("room");
					t = "review session";
				%>
					<tr>
						<td><%=sid%></td>
						<td><%=wid%></td>
						<td><%=d%></td>
						<td><%=st2%></td>
						<td><%=et2%></td>
						<td><%=b%></td>
						<td><%=rn%></td>
						<td><%=t%></td>
						<td>
							<form action="subsection.jsp" method="POST">
								<input type="hidden" name="action" value="delete">
								<input type="hidden" name="id" value="<%=wid%>">
								<input type="hidden" name="type" value="<%=t%>">
								<input type="submit" value="Delete">
							</form>
						</td>
						<td>
							<form action="subsection.jsp" method="POST">
							<input type="hidden" name="action" value="updatepre">
							<input type="hidden" name="idsection" value="<%=sid%>">
							<input type="hidden" name="type" value="review">
							<input type="hidden" name="idreviewsession" value="<%=wid%>">
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
			else if (action != null && action.equals("updatepre"))
			{
				String type = request.getParameter("type");
				String idweekly = request.getParameter("idweekly");
				String idreviewsession = request.getParameter("idreviewsession");
				System.out.println(type);
				System.out.println(idweekly);
				System.out.println(idreviewsession);
				
				int myid = -1;
				String idname = "";
				%>
				<form action="subsection.jsp" method="POST">
				<%
			
				if (type != null && (type.equals("lecture") || type.equals("discussion")))
				{
					idname = "idweekly";
					myid = Integer.parseInt(idweekly);
					%>
					<h3>Updating <%=type%> <%=idweekly%>:</h3>
			
					Days of Week:
					<input type="checkbox" name="days" value="M">M
					<input type="checkbox" name="days" value="Tu">Tu
					<input type="checkbox" name="days" value="W">W
					<input type="checkbox" name="days" value="Th">Th
					<input type="checkbox" name="days" value="F">F
					<input type="checkbox" name="days" value="Sa">Sa
					<input type="checkbox" name="days" value="Su">Su
					<%
				}
			
				else if (type != null && type.equals("review"))
				{
					idname = "idreviewsession";
					myid = Integer.parseInt(idreviewsession);
					%>
					<h3>Updating Review Session <%=idreviewsession %>:</h3>		
					<select name="month">
						<option value="01">1</option>
						<option value="02">2</option>
						<option value="03">3</option>
						<option value="04">4</option>
						<option value="05">5</option>
						<option value="06">6</option>
						<option value="07">7</option>
						<option value="08">8</option>
						<option value="09">9</option>
						<option value="10">10</option>
						<option value="11">11</option>
						<option value="12">12</option>
					</select>
					/	
					<select name="day">
						<option value="01">1</option>
						<option value="02">2</option>
						<option value="03">3</option>
						<option value="04">4</option>
						<option value="05">5</option>
						<option value="06">6</option>
						<option value="07">7</option>
						<option value="08">8</option>
						<option value="09">9</option>
						<option value="10">10</option>
						<option value="11">11</option>
						<option value="12">12</option>
						<option value="13">13</option>
						<option value="14">14</option>
						<option value="15">15</option>
						<option value="16">16</option>
						<option value="17">17</option>
						<option value="18">18</option>
						<option value="19">19</option>
						<option value="20">20</option>
						<option value="21">21</option>
						<option value="22">22</option>
						<option value="23">23</option>
						<option value="24">24</option>
						<option value="25">25</option>
						<option value="26">26</option>
						<option value="27">27</option>
						<option value="28">28</option>
						<option value="29">29</option>
						<option value="30">30</option>
						<option value="31">31</option>
					</select>
					/
					<select name="year">
					<%
				int year;
				sql3 = "SELECT DISTINCT year FROM quarter ORDER BY year";
				ps3 = conn.prepareStatement(sql3);
				rs3 = ps3.executeQuery();
				while (rs3.next())
				{
					year = rs3.getInt("year");
				%>
					<option value="<%=year%>"><%=year%></option>
				<% 
				}
				%>
					</select>
					<%
				}	
				%>
				Start Time:
				<select name="starth">
					<option value="01">1</option>
					<option value="02">2</option>
					<option value="03">3</option>
					<option value="04">4</option>
					<option value="05">5</option>
					<option value="06">6</option>
					<option value="07">7</option>
					<option value="08">8</option>
					<option value="09">9</option>
					<option value="10">10</option>
					<option value="11">11</option>
					<option value="11">12</option>
				</select>
				:
				<select name="startm">
					<option value="00">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
				<select name="startmode">
					<option value="am">AM</option>
					<option value="pm">PM</option>
				</select>
				End Time:
				<select name="endh">
					<option value="01">01</option>
					<option value="02">02</option>
					<option value="03">03</option>
					<option value="04">04</option>
					<option value="05">05</option>
					<option value="06">06</option>
					<option value="07">07</option>
					<option value="08">08</option>
					<option value="09">09</option>
					<option value="10">10</option>
					<option value="11">11</option>
					<option value="12">12</option>
				</select>
				:
				<select name="endm">
					<option value="00">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
				<select name="endmode">
					<option value="am">AM</option>
					<option value="pm">PM</option>
				</select>
			
				<label for="building">Location:</label>
				<input type="text" name="building">
				<label for="room">Room:</label>
				<input type="text" name="room">
				<input type="hidden" name="action" value="update">
				<input type="hidden" name="type" value="<%=type%>">
				<input type="hidden" name="<%=idname%>" value="<%=myid%>">
				<input type="submit">
			</form>
			<%
			System.out.println(idname);
			System.out.println(myid);
		}
		else if (action != null && action.equals("update"))
		{
			String type = request.getParameter("type");
			String idweekly = request.getParameter("idweekly");
			String idreviewsession = request.getParameter("idreviewsession");
			String building = request.getParameter("building");
			String room = request.getParameter("room");
			String starth = request.getParameter("starth");
			String startm = request.getParameter("startm");
			String startmode = request.getParameter("startmode");
			String endh = request.getParameter("endh");
			String endm = request.getParameter("endm");
			String endmode = request.getParameter("endmode");
		
			if (startmode.equals("pm"))
			{
				int starthint = Integer.parseInt(starth);
				starthint += 12;
				starthint %= 24;
				starth = "" + starthint;
			}
		
			if (endmode.equals("pm"))
			{
				int endhint = Integer.parseInt(endh);
				endhint += 12;
				endh = "" + endhint;
			}

			String startTimeString = starth + ":" + startm + ":00";
			String endTimeString = endh + ":" + endm + ":00";
			
			String daysString = null;
			String dateString = null;
		
			String dayType = "";
			String dayString = "";
			
			int dayString2 = 0;
			int [] dayKeys = {64, 32, 16, 8, 4, 2, 1};
			HashMap<String,Integer> dayCodes = new HashMap<String,Integer>();
			String [] dayCodesString = {"M", "Tu", "W", "Th", "F", "Sa", "Su"};

			for (int i = 0; i < 7; i++)
			{
				dayCodes.put(dayCodesString[i], dayKeys[i]);
			}
		
			if (type != null && (type.equals("lecture") || (type.equals("discussion"))))
			{
				String dummyDate = "2014-01-01";
				java.sql.Date dummyDateObj = java.sql.Date.valueOf(dummyDate);
				java.sql.Timestamp startTime = java.sql.Timestamp.valueOf(dummyDate + " " + startTimeString);
				java.sql.Timestamp endTime = java.sql.Timestamp.valueOf(dummyDate + " " + endTimeString);
				String [] days = request.getParameterValues("days");
				
				int dayslength = days.length;
				dayType = "Days of Week";
				for (int i = 0; i < dayslength; i++)
				{
					dayString2 = dayString2 | dayCodes.get(days[i]);
				}
				for (int i = 0; i < dayslength; i++)
				{
					dayString += days[i];
				}
			
				sql1 = "UPDATE weekly SET building = ?, room = ?, day_of_week = ?, start_time = ?, end_time = ?, type = ? WHERE idweekly = ?";
				ps1 = conn.prepareStatement(sql1);
				ps1.setString(1, building);
				ps1.setString(2, room);
				ps1.setInt(3, dayString2);
				ps1.setTimestamp(4, startTime);
				ps1.setTimestamp(5, endTime);
				ps1.setString(6, type);
				ps1.setInt(7, Integer.parseInt(idweekly));
				ps1.executeUpdate();
				conn.commit();
				
				response.sendRedirect("subsection.jsp?action=view");
			}
		
			else if (type != null && type.equals("review"))
			{
				String month = request.getParameter("month");
				String day = request.getParameter("day");
				String year = request.getParameter("year");
				dayType = "Date";
				dayString = year + "-" + month + "-" + day;
				java.sql.Date revDate = java.sql.Date.valueOf(dayString);
				java.sql.Timestamp startTime = java.sql.Timestamp.valueOf(dayString + " " + startTimeString);
				java.sql.Timestamp endTime = java.sql.Timestamp.valueOf(dayString + " " + endTimeString);
			
				sql1 = "UPDATE reviewsession SET time = ?, start_time = ?, end_time = ?, building = ?, room = ? WHERE idreviewsession = ?";
				ps1 = conn.prepareStatement(sql1);
				ps1.setDate(1, revDate);
				ps1.setTimestamp(2, startTime);
				ps1.setTimestamp(3, endTime);
				ps1.setString(4, building);
				ps1.setString(5, room);
				ps1.setInt(6, Integer.parseInt(idreviewsession));
				ps1.executeUpdate();
				conn.commit();
				response.sendRedirect("subsection.jsp?action=view");
			}
			%>
			<h3>Successfully added a <%=type%></h3>
			<h3>Summary:</h3>
			<h4><%=dayType%>: <%=dayString%></h4>
			<h4>Start Time: <%=startTimeString%></h4>
			<h4>End Time: <%=endTimeString%></h4>
			<form action="subsection.jsp" method="POST">
				<input type="submit" value="Add more subsections">
			</form>
			<form action="section.jsp" method="POST">
				<input type="submit" value="Add a new section">
			</form>
			<form action="class_entry_form.jsp">
				<input type="submit" value="Add a new class">
			</form>
			<%
					
		}
		
			
			else if (action != null && action.equals("delete"))
			{
				String typet = request.getParameter("type");
				int id = Integer.parseInt(request.getParameter("id"));
				if (typet != null && typet.equals("weekly"))
				{
					sql1 = "DELETE FROM weekly WHERE idweekly = ?";
					ps1 = conn.prepareStatement(sql1);
					ps1.setInt(1, id);
					ps1.executeUpdate();
					conn.commit();
				}
				else if (typet != null && typet.equals("review session"))
				{
					sql1 = "DELETE FROM reviewsession WHERE idreviewsession = ?";
					ps1 = conn.prepareStatement(sql1);
					ps1.setInt(1, id);
					ps1.executeUpdate();
					conn.commit();
				}	
				response.sendRedirect("subsection.jsp?action=view");
			}
			
			else if (action != null && action.equals("insert"))
			{
				int idsection_insert = Integer.parseInt(request.getParameter("idsection"));
				String type = request.getParameter("type");
				String building = request.getParameter("building");
				String room = request.getParameter("room");
				String starth = request.getParameter("starth");
				String startm = request.getParameter("startm");
				String startmode = request.getParameter("startmode");
				String endh = request.getParameter("endh");
				String endm = request.getParameter("endm");
				String endmode = request.getParameter("endmode");
			
				if (startmode.equals("pm"))
				{
					int starthint = Integer.parseInt(starth);
					starthint += 12;
					starthint %= 24;
					starth = "" + starthint;
				}
			
				if (endmode.equals("pm"))
				{
					int endhint = Integer.parseInt(endh);
					endhint += 12;
					endh = "" + endhint;
				}
	
				String startTimeString = starth + ":" + startm + ":00";
				String endTimeString = endh + ":" + endm + ":00";
				
				String daysString = null;
				String dateString = null;
			
				String dayType = "";
				String dayString = "";
				int dayString2 = 0;
				int [] dayKeys = {64, 32, 16, 8, 4, 2, 1};
				HashMap<String,Integer> dayCodes = new HashMap<String,Integer>();
				String [] dayCodesString = {"M", "Tu", "W", "Th", "F", "Sa", "Su"};

				for (int i = 0; i < 7; i++)
				{
					dayCodes.put(dayCodesString[i], dayKeys[i]);
				}
			
				if (type != null && (type.equals("lecture") || (type.equals("discussion"))))
				{
					String dummyDate = "2014-01-01";
					java.sql.Date dummyDateObj = java.sql.Date.valueOf(dummyDate);
					java.sql.Time startTime = java.sql.Time.valueOf(startTimeString);
					java.sql.Time endTime = java.sql.Time.valueOf(endTimeString);
					String [] days = request.getParameterValues("days");
					int dayslength = days.length;
					dayType = "Days of Week";
					int j = 0;
					for (int i = 0; i < dayslength; i++)
					{
						dayString2 = dayString2 | dayCodes.get(days[i]);
						j++;
					}
				
					sql1 = "INSERT INTO weekly (building, room, day_of_week, start_time, end_time, type) VALUES (?, ?, ?, ?, ?, ?) RETURNING idweekly";
					ps1 = conn.prepareStatement(sql1);
					ps1.setString(1, building);
					ps1.setString(2, room);
					ps1.setInt(3, dayString2);
					ps1.setTime(4, startTime);
					ps1.setTime(5, endTime);
					ps1.setString(6, type);
					ps1.execute();
					rs1 = ps1.getResultSet();
					rs1.next();
					int idweekly = rs1.getInt("idweekly");
					sql2 = "INSERT INTO section_weekly (idsection, idweekly) VALUES (?,?)";
					ps2 = conn.prepareStatement(sql2);
					ps2.setInt(1, idsection_insert);
					ps2.setInt(2, idweekly);
					ps2.executeUpdate();
					conn.commit();
				}
			
				else if (type != null && type.equals("review"))
				{
					String month = request.getParameter("month");
					String day = request.getParameter("day");
					String year = request.getParameter("year");
					dayType = "Date";
					dayString = year + "-" + month + "-" + day;
					java.sql.Date revDate = java.sql.Date.valueOf(dayString);
					java.sql.Timestamp startTime = java.sql.Timestamp.valueOf(dayString2 + " " + startTimeString);
					java.sql.Timestamp endTime = java.sql.Timestamp.valueOf(dayString2 + " " + endTimeString);
				
					sql1 = "INSERT INTO reviewsession (time, start_time, end_time, building, room) VALUES (?, ?, ?, ?, ?) RETURNING idreviewsession";
					ps1 = conn.prepareStatement(sql1);
					ps1.setDate(1, revDate);
					ps1.setTimestamp(2, startTime);
					ps1.setTimestamp(3, endTime);
					ps1.setString(4, building);
					ps1.setString(5, room);
					ps1.execute();
					rs1 = ps1.getResultSet();
					rs1.next();
					int idreview = rs1.getInt("idreviewsession");
					sql2 = "INSERT INTO section_reviewsession (idsection, idreviewsession) VALUES (?,?)";
					ps2 = conn.prepareStatement(sql2);
					ps2.setInt(1, idsection_insert);
					ps2.setInt(2, idreview);
					ps2.executeUpdate();
					conn.commit();
				}
				session.setAttribute("success", "Insert");
				session.setAttribute("idsection", idsection_insert);
				response.sendRedirect("subsection.jsp?action=view");
			}
			
			else if (action != null && (action.equals("create") || action.equals("create_specific")))
			{
				int idsection_create = Integer.parseInt(request.getParameter("idsection"));
				
				sql2 = "SELECT * FROM quarter_course_class__instance, class, quarter, course_coursenumber, coursenumber, faculty_class_section" +
				      " WHERE faculty_class_section.idsection = ?" +
				      " AND faculty_class_section.idclass = quarter_course_class__instance.idclass" +
				      " AND quarter_course_class__instance.idclass = class.idclass" + 
				      " AND quarter_course_class__instance.idquarter = quarter.idquarter" + 
				      " AND quarter_course_class__instance.idcourse = course_coursenumber.idcourse" + 
				      " AND course_coursenumber.idcoursenumber = coursenumber.idcoursenumber";
				ps2 = conn.prepareStatement(sql2);
				ps2.setInt(1, idsection_create);
				rs2 = ps2.executeQuery();
				rs2.next();
				String quarter = rs2.getString("season") + " " + rs2.getString("year");
				String title = rs2.getString("title");
				String idcourse = rs2.getString("idcourse");
				String courseno_create = rs2.getString("number");
				while (rs2.next())
				{
					courseno_create += " / ";
					courseno_create += rs2.getString("number");
				}
			
				
				%>
				
				<h4>Course and Class Information</h4>
				<ul>
					<li>Course ID: <%=idcourse%></li>
					<li>Course Number(s): <%=courseno_create%></li>
					<li>Class ID: <%=idsection_create%></li>
					<li>Title: <%=title%></li>
					<li>Quarter: <%=quarter%></li>
				</ul>
				<%
				if (action.equals("create"))
				{
				%>
					<a href="subsection.jsp?idsection=<%=idsection_create%>&action=create_specific&type=lecture"><button>Add Lecture</button></a>
					<a href="subsection.jsp?idsection=<%=idsection_create%>&action=create_specific&type=discussion"><button>Add Discussion</button></a>
					<a href="subsection.jsp?idsection=<%=idsection_create%>&action=create_specific&type=review"><button>Add Review Session</button></a>
				<%
				}
				else
				{
			String type = request.getParameter("type");
			%>
			<form action="subsection.jsp" method="POST">
			<%
		
			if (type != null && (type.equals("lecture") || type.equals("discussion")))
			{
				%>
				<h3>Adding a <%=type%>:</h3>
		
				Days of Week:
				<input type="checkbox" name="days" value="M">M
				<input type="checkbox" name="days" value="Tu">Tu
				<input type="checkbox" name="days" value="W">W
				<input type="checkbox" name="days" value="Th">Th
				<input type="checkbox" name="days" value="F">F
				<input type="checkbox" name="days" value="Sa">Sa
				<input type="checkbox" name="days" value="Su">Su
		
				<input type="hidden" name="action" value="insert">
				<input type="hidden" name="type" value="<%=type%>">	
				<%
			}
		
			else if (type != null && type.equals("review"))
			{
				%>
				<h3>Adding a Review Session:</h3>		
				<select name="month">
					<option value="01">1</option>
					<option value="02">2</option>
					<option value="03">3</option>
					<option value="04">4</option>
					<option value="05">5</option>
					<option value="06">6</option>
					<option value="07">7</option>
					<option value="08">8</option>
					<option value="09">9</option>
					<option value="10">10</option>
					<option value="11">11</option>
					<option value="12">12</option>
				</select>
				/	
				<select name="day">
					<option value="01">1</option>
					<option value="02">2</option>
					<option value="03">3</option>
					<option value="04">4</option>
					<option value="05">5</option>
					<option value="06">6</option>
					<option value="07">7</option>
					<option value="08">8</option>
					<option value="09">9</option>
					<option value="10">10</option>
					<option value="11">11</option>
					<option value="12">12</option>
					<option value="13">13</option>
					<option value="14">14</option>
					<option value="15">15</option>
					<option value="16">16</option>
					<option value="17">17</option>
					<option value="18">18</option>
					<option value="19">19</option>
					<option value="20">20</option>
					<option value="21">21</option>
					<option value="22">22</option>
					<option value="23">23</option>
					<option value="24">24</option>
					<option value="25">25</option>
					<option value="26">26</option>
					<option value="27">27</option>
					<option value="28">28</option>
					<option value="29">29</option>
					<option value="30">30</option>
					<option value="31">31</option>
				</select>
				/
				<select>
				<%
				int year;
				sql3 = "SELECT DISTINCT year FROM quarter ORDER BY year";
				ps3 = conn.prepareStatement(sql3);
				rs3 = ps3.executeQuery();
				while (rs3.next())
				{
					year = rs3.getInt("year");
				%>
					<option value="<%=year%>"><%=year%></option>
				<% 
				}
				%>
				</select>
				<br><br>
				<input type="hidden" name="action" value="insert">
				<input type="hidden" name="type" value="review">
				<%
			}	
			%>
			Start Time:
			<select name="starth">
				<option value="01">1</option>
				<option value="02">2</option>
				<option value="03">3</option>
				<option value="04">4</option>
				<option value="05">5</option>
				<option value="06">6</option>
				<option value="07">7</option>
				<option value="08">8</option>
				<option value="09">9</option>
				<option value="10">10</option>
				<option value="11">11</option>
				<option value="11">12</option>
			</select>
			:
			<select name="startm">
				<option value="00">00</option>
				<option value="10">10</option>
				<option value="20">20</option>
				<option value="30">30</option>
				<option value="40">40</option>
				<option value="50">50</option>
			</select>
			<select name="startmode">
				<option value="am">AM</option>
				<option value="pm">PM</option>
			</select>
			End Time:
			<select name="endh">
				<option value="01">01</option>
				<option value="02">02</option>
				<option value="03">03</option>
				<option value="04">04</option>
				<option value="05">05</option>
				<option value="06">06</option>
				<option value="07">07</option>
				<option value="08">08</option>
				<option value="09">09</option>
				<option value="10">10</option>
				<option value="11">11</option>
				<option value="12">12</option>
			</select>
			:
			<select name="endm">
				<option value="00">00</option>
				<option value="10">10</option>
				<option value="20">20</option>
				<option value="30">30</option>
				<option value="40">40</option>
				<option value="50">50</option>
			</select>
			<select name="endmode">
				<option value="am">AM</option>
				<option value="pm">PM</option>
			</select>
		
			<label for="building">Location:</label>
			<input type="text" name="building">
			<label for="room">Room:</label>
			<input type="text" name="room">
			<input type="hidden" name="idsection" value="<%=idsection_create%>">
			<input type="hidden" name="action" value="insert">
			<input type="submit">
		</form>
		<%
				
		}
			}
		
		else
		{
			%>
			<h3>Select section:</h3>
			<%
			
			sql1 = "SELECT class.title, faculty_class_section.idclass, faculty_class_section.faculty_name, faculty_class_section.idsection" +
			" FROM class, faculty_class_section" +
			" WHERE class.idclass = faculty_class_section.idclass"; 
			ps1 = conn.prepareStatement(sql1);
			rs1 = ps1.executeQuery();
			
			if (!(rs1.isBeforeFirst()))
			{
				%>
				<h3>Cannot process request: No classes in database</h3>
				<a href="class_entry_form.jsp"><button>Add Classes</button></a>
				<%
			}
			else
			{
				%>
				<form action="subsection.jsp" method="GET">
				<select name="idsection"><%
				int idclass;
				int idsection_select;
				String title;
				String faculty;
				while (rs1.next())
				{
					idclass = rs1.getInt("idclass");
					idsection_select = rs1.getInt("idsection");
					title = rs1.getString("title");
					faculty = rs1.getString("faculty_name");
					%>
						<option value="<%=idsection_select%>">CID: <%=idclass%> - SID:<%=idsection_select%> - <%=title%> - <%=faculty%></option>
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