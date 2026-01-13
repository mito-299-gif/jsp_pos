<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%

if (session.getAttribute("userId") == null) {
    response.sendRedirect("../index.jsp");
    return;
}

int userId = (Integer) session.getAttribute("userId");
DecimalFormat df = new DecimalFormat("#,##0");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");


String dateFrom = request.getParameter("dateFrom");
String dateTo = request.getParameter("dateTo");
String searchCode = request.getParameter("searchCode");
%>