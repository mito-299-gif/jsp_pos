<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
String exportCode = request.getParameter("export_code");
if (exportCode == null || exportCode.trim().isEmpty()) {
    out.println("<div class='alert alert-danger'>ไม่พบข้อมูลคำสั่งซื้อ</div>");
    return;
}

DecimalFormat df = new DecimalFormat("#,##0.00");
SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
        "root", "Admin"
    );

    // Get order header info
    String headerSql = "SELECT DISTINCT e.export_code, e.export_date, e.user_id, e.notes, " +
                      "u.full_name as user_name, " +
                      "SUM(e.total_price) as total_amount, " +
                      "COUNT(e.product_id) as item_count " +
                      "FROM exports e " +
                      "LEFT JOIN users u ON e.user_id = u.id " +
                      "WHERE e.export_code = ? " +
                      "GROUP BY e.export_code, e.export_date, e.user_id, e.notes, u.full_name";

    ps = conn.prepareStatement(headerSql);
    ps.setString(1, exportCode);
    rs = ps.executeQuery();

    Map<String, Object> orderHeader = null;
    if (rs.next()) {
        orderHeader = new HashMap<>();
        orderHeader.put("export_code", rs.getString("export_code"));
        orderHeader.put("export_date", rs.getTimestamp("export_date"));
        orderHeader.put("user_name", rs.getString("user_name"));
        orderHeader.put("total_amount", rs.getDouble("total_amount"));
        orderHeader.put("item_count", rs.getInt("item_count"));
        orderHeader.put("notes", rs.getString("notes"));
    }
    rs.close();
    ps.close();

    if (orderHeader == null) {
        out.println("<div class='alert alert-warning'>ไม่พบข้อมูลคำสั่งซื้อ</div>");
        return;
    }

    // Get order items
    String itemsSql = "SELECT e.product_id, e.quantity, e.unit_price, e.total_price, " +
                     "p.product_name, p.product_code " +
                     "FROM exports e " +
                     "LEFT JOIN products p ON e.product_id = p.id " +
                     "WHERE e.export_code = ? " +
                     "ORDER BY p.product_name";

    ps = conn.prepareStatement(itemsSql);
    ps.setString(1, exportCode);
    rs = ps.executeQuery();

    List<Map<String, Object>> orderItems = new ArrayList<>();
    while (rs.next()) {
        Map<String, Object> item = new HashMap<>();
        item.put("product_id", rs.getInt("product_id"));
        item.put("product_code", rs.getString("product_code"));
        item.put("product_name", rs.getString("product_name"));
        item.put("quantity", rs.getInt("quantity"));
        item.put("unit_price", rs.getDouble("unit_price"));
        item.put("total_price", rs.getDouble("total_price"));
        orderItems.add(item);
    }

%>
<div class="order-details">
    <!-- Order Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h6><strong>เลขที่สั่งซื้อ:</strong> <%= orderHeader.get("export_code") %></h6>
            <p><strong>วันที่:</strong> <%= dateFormat.format(orderHeader.get("export_date")) %></p>
            <p><strong>ผู้บันทึก:</strong> <%= orderHeader.get("user_name") %></p>
        </div>
        <div class="col-md-6 text-end">
            <h5 class="text-success">รวมทั้งหมด: ฿<%= df.format(orderHeader.get("total_amount")) %></h5>
            <p class="mb-0"><%= orderHeader.get("item_count") %> รายการ</p>
        </div>
    </div>

    <% if (orderHeader.get("notes") != null && !orderHeader.get("notes").toString().trim().isEmpty()) { %>
    <div class="mb-4">
        <strong>หมายเหตุ:</strong> <%= orderHeader.get("notes") %>
    </div>
    <% } %>

    <!-- Order Items -->
    <div class="table-responsive">
        <table class="table table-striped">
            <thead class="table-dark">
                <tr>
                    <th>รหัสสินค้า</th>
                    <th>ชื่อสินค้า</th>
                    <th class="text-center">จำนวน</th>
                    <th class="text-end">ราคาต่อหน่วย</th>
                    <th class="text-end">รวม</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> item : orderItems) { %>
                <tr>
                    <td><%= item.get("product_code") %></td>
                    <td><%= item.get("product_name") %></td>
                    <td class="text-center"><%= item.get("quantity") %></td>
                    <td class="text-end">฿<%= df.format(item.get("unit_price")) %></td>
                    <td class="text-end">฿<%= df.format(item.get("total_price")) %></td>
                </tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr class="table-dark">
                    <th colspan="4" class="text-end">รวมทั้งหมด:</th>
                    <th class="text-end">฿<%= df.format(orderHeader.get("total_amount")) %></th>
                </tr>
            </tfoot>
        </table>
    </div>

    <!-- Print Button -->
    <div class="text-center mt-4">
        <button class="btn btn-primary" onclick="printOrder()">
            <i class="bi bi-printer"></i> พิมพ์ใบสั่งซื้อ
        </button>
    </div>
</div>

<style>
.order-details {
    max-height: 70vh;
    overflow-y: auto;
}
</style>

<script>
function printOrder() {
    // Create a new window for printing
    const printWindow = window.open('', '_blank', 'width=800,height=600');

    // Get the order content
    const orderContent = document.querySelector('.order-details').innerHTML;

    // Create the print HTML using string concatenation
    const printHTML = '<!DOCTYPE html>' +
        '<html>' +
        '<head>' +
            '<title>ใบสั่งซื้อสินค้า</title>' +
            '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">' +
            '<style>' +
                'body {' +
                    'font-family: \'TH Sarabun New\', \'Sarabun\', Arial, sans-serif;' +
                    'font-size: 14px;' +
                    'line-height: 1.4;' +
                    'margin: 20px;' +
                    'color: #333;' +
                '}' +
                '.print-header {' +
                    'text-align: center;' +
                    'border-bottom: 2px solid #333;' +
                    'padding-bottom: 10px;' +
                    'margin-bottom: 20px;' +
                '}' +
                '.print-header h2 {' +
                    'margin: 0;' +
                    'color: #333;' +
                    'font-size: 24px;' +
                    'font-weight: bold;' +
                '}' +
                '.order-details {' +
                    'max-height: none !important;' +
                    'overflow: visible !important;' +
                '}' +
                'table {' +
                    'width: 100%;' +
                    'border-collapse: collapse;' +
                    'margin-bottom: 20px;' +
                '}' +
                'th, td {' +
                    'border: 1px solid #ddd;' +
                    'padding: 8px;' +
                    'text-align: left;' +
                '}' +
                'th {' +
                    'background-color: #f8f9fa;' +
                    'font-weight: bold;' +
                '}' +
                '.text-center {' +
                    'text-align: center;' +
                '}' +
                '.text-end {' +
                    'text-align: right;' +
                '}' +
                '.text-success {' +
                    'color: #198754 !important;' +
                '}' +
                '.fw-bold {' +
                    'font-weight: bold;' +
                '}' +
                '.mb-2, .mb-4 {' +
                    'margin-bottom: 0.5rem;' +
                '}' +
                '.mb-4 {' +
                    'margin-bottom: 1rem;' +
                '}' +
                '@media print {' +
                    'body { margin: 0; }' +
                    '.no-print { display: none !important; }' +
                '}' +
            '</style>' +
        '</head>' +
        '<body>' +
            '<div class="print-header">' +
                '<h2>ใบสั่งซื้อสินค้า</h2>' +
                '<p>Export Order Receipt</p>' +
            '</div>' +
            '<div class="order-details">' +
                orderContent +
            '</div>' +
            '<div class="text-center no-print" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">' +
                '<small>พิมพ์เมื่อ: ' + new Date().toLocaleString('th-TH') + '</small>' +
            '</div>' +
        '</body>' +
        '</html>';

    // Write to the new window
    printWindow.document.open();
    printWindow.document.write(printHTML);
    printWindow.document.close();

    // Wait for content to load, then print
    printWindow.onload = function() {
        // Remove the print button from the printed content
        const printBtn = printWindow.document.querySelector('.text-center button');
        if (printBtn) {
            printBtn.style.display = 'none';
        }

        // Focus and print
        printWindow.focus();
        printWindow.print();

        // Close the window after printing (optional)
        setTimeout(function() {
            printWindow.close();
        }, 1000);
    };
}
</script>

<%
} catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'>เกิดข้อผิดพลาดในการโหลดข้อมูล: " + e.getMessage() + "</div>");
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (ps != null) try { ps.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>}
