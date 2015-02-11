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

	String todo = request.getParameter("todo");

	if (todo == null)
	{
		%><h3>Error: Please use Class Entry Form</h3>
		
		<form action="class_entry_form.jsp">
		<input type="submit" value="Go To Class Entry Form">
		</form><%
	}
	%><form action="section.jsp"><%
	if (todo.equals("review"))
	{
		%><h3>Adding a Review Session:</h3>
		<input type="hidden" name="result" value="revadd">
		
		<select name="month">
			<option value="1">1</option>
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
			<option value="7">7</option>
			<option value="8">8</option>
			<option value="9">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
		</select>
		/
		
		<select name="day">
			<option value="1">1</option>
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
			<option value="7">7</option>
			<option value="8">8</option>
			<option value="9">9</option>
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
		
		
		<% 
	}
	else if (todo.equals("lecture"))
	{
		%><h3>Adding a Lecture:</h3>
		<input type="hidden" name="result" value="lecadd">
		Days of Week:
		<input type="checkbox" name="day" value="M">M
		<input type="checkbox" name="day" value="Tu">Tu
		<input type="checkbox" name="day" value="W">W
		<input type="checkbox" name="day" value="Th">Th
		<input type="checkbox" name="day" value="F">F
		<input type="checkbox" name="day" value="Sa">Sa
		<input type="checkbox" name="day" value="Su">Su<%
	}
	else
	{
		%><h3>Adding a Discussion:</h3>
		<input type="hidden" name="result" value="discadd">
		Days of Week:
		<input type="checkbox" name="day" value="M">M
		<input type="checkbox" name="day" value="Tu">Tu
		<input type="checkbox" name="day" value="W">W
		<input type="checkbox" name="day" value="Th">Th
		<input type="checkbox" name="day" value="F">F
		<input type="checkbox" name="day" value="Sa">Sa
		<input type="checkbox" name="day" value="Su">Su
		<%
	}

%>
		Start Time:
		<select name="starth">
			<option value="1">1</option>
			<option value="1">2</option>
			<option value="1">3</option>
			<option value="1">4</option>
			<option value="1">5</option>
			<option value="1">6</option>
			<option value="1">7</option>
			<option value="1">8</option>
			<option value="1">9</option>
			<option value="1">10</option>
			<option value="1">11</option>
			<option value="1">12</option>
		</select>
		:
		<select name="startm">
		<option value="1">00</option>
			<option value="1">10</option>
			<option value="1">20</option>
			<option value="1">30</option>
			<option value="1">40</option>
			<option value="1">50</option>
		</select>
		<select name="startmode">
		<option value="am">AM</option>
			<option value="pm">PM</option>
		</select>
		End Time:
		<select name="endh">
			<option value="1">1</option>
			<option value="1">2</option>
			<option value="1">3</option>
			<option value="1">4</option>
			<option value="1">5</option>
			<option value="1">6</option>
			<option value="1">7</option>
			<option value="1">8</option>
			<option value="1">9</option>
			<option value="1">10</option>
			<option value="1">11</option>
			<option value="1">12</option>
		</select>
		:
		<select name="endm">
		<option value="1">00</option>
			<option value="1">10</option>
			<option value="1">20</option>
			<option value="1">30</option>
			<option value="1">40</option>
			<option value="1">50</option>
		</select>
		<select name="endmode">
		<option value="am">AM</option>
			<option value="pm">PM</option>
		</select>
		
		<label for="location">Location:</label>
		<input type="text" name="location">
	<input type="submit">
</form>
</body>
</html>