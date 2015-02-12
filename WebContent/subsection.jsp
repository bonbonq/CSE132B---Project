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
	String sessionok = (String) session.getAttribute("sessionok");
	if (sessionok == null || !(sessionok.equals("okay")))
	{
		%><h2>ERROR: Session expired or no valid section chosen. Please return to home page and try again.</h2>
		<form action="index.jsp" method="POST">
			<input type="submit" value="Return to home page">
		</form>
		<%
	}
	else
	{		
		String action = request.getParameter("action");
		String type = request.getParameter("type");
		String dept = (String) session.getAttribute("dept");
		String courseno = (String) session.getAttribute("courseno");
		Integer idsection = (Integer) session.getAttribute("idsection");
		
		%>
		<h2>Sub-section Add Form</h2>
		<h3>Department:<%=dept%></h3>
		<h3>Course Number: <%=courseno%></h3>
		<h3>Section ID: <%=idsection%></h3>
		<%
		
		if (action != null && action.equals("insert"))
		{
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
		
			try
			{
				Class.forName("org.postgresql.Driver");
				conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
				conn.setAutoCommit(false);
				
				String dayType = "";
				String dayString = "";
			
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
						dayString += days[i];
				
					sql1 = "INSERT INTO weekly (building, room, day_of_week, start_time, end_time, type) VALUES (?, ?, ?, ?, ?, ?) RETURNING idweekly";
					ps1 = conn.prepareStatement(sql1);
					ps1.setString(1, building);
					ps1.setString(2, room);
					ps1.setDate(3, dummyDateObj);
					ps1.setTimestamp(4, startTime);
					ps1.setTimestamp(5, endTime);
					ps1.setString(6, type);
					ps1.execute();
					rs1 = ps1.getResultSet();
					rs1.next();
					int idweekly = rs1.getInt("idweekly");
					sql2 = "INSERT INTO section_weekly (idsection, idweekly) VALUES (?,?)";
					ps2 = conn.prepareStatement(sql2);
					ps2.setInt(1, idsection);
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
					java.sql.Timestamp startTime = java.sql.Timestamp.valueOf(dayString + " " + startTimeString);
					java.sql.Timestamp endTime = java.sql.Timestamp.valueOf(dayString + " " + endTimeString);
				
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
					ps2.setInt(1, idsection);
					ps2.setInt(2, idreview);
					ps2.executeUpdate();
					conn.commit();
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
		}	
		
		else if (action != null && action.equals("create"))
		{
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
				<select name="year">
					<option value="2015">2015</option>
					<option value="2016">2016</option>
					<option value="2017">2017</option>
				</select>
				
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
			<input type="hidden" name="action" value="insert">
			<input type="submit">
		</form>
		<%
	}
	else
	{
		%>
		<form action="subsection.jsp" method="POST">
			<input type="hidden" name="action" value="create">
			<input type="hidden" name="type" value="lecture">
			<input type="submit" value="Add Lecture">
		</form>
		
		<form action="subsection.jsp" method="POST">
			<input type="hidden" name="action" value="create">
			<input type="hidden" name="type" value="discussion">
			<input type="submit" value="Add Discussion">
		</form>
		
		<form action="subsection.jsp" method="POST">
			<input type="hidden" name="action" value="create">
			<input type="hidden" name="type" value="review">
			<input type="submit" value="Add Review Session">
		</form>
		<%
	}
}
%>
</body>
</html>