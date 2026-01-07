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
    console.log('Print function called');

    try {
        // Simple approach: just use window.print() on current content
        const orderDetails = document.querySelector('.order-details');
        if (!orderDetails) {
            console.error('Order details not found');
            alert('ไม่พบข้อมูลสำหรับพิมพ์');
            return;
        }

        // Create a print-friendly version
        const originalContent = document.body.innerHTML;

        // Create print header
        const printHeader = '<div style="text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px;">' +
            '<h2 style="margin: 0; color: #333;">ใบสั่งซื้อสินค้า</h2>' +
            '<p style="margin: 5px 0;">Export Order Receipt</p>' +
            '</div>';

        // Get the order content and make it print-friendly
        const orderContent = orderDetails.outerHTML.replace(/max-height: 70vh/g, 'max-height: none')
                                                   .replace(/overflow-y: auto/g, 'overflow: visible');

        // Replace body content for printing
        document.body.innerHTML = '<div style="font-family: Arial, sans-serif; margin: 20px;">' +
            printHeader +
            '<div style="margin-top: 20px;">' + orderContent + '</div>' +
            '<div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666;">' +
            'พิมพ์เมื่อ: ' + new Date().toLocaleString('th-TH') +
            '</div>' +
            '</div>';

        // Hide the print button
        const printBtn = document.querySelector('.text-center button');
        if (printBtn) {
            printBtn.style.display = 'none';
        }

        // Add print styles
        const style = document.createElement('style');
        style.textContent = `
            @media print {
                body { margin: 0; font-size: 12px; }
                .order-details { max-height: none !important; overflow: visible !important; }
                table { font-size: 11px; width: 100%; }
                button { display: none !important; }
            }
        `;
        document.head.appendChild(style);

        // Print
        window.print();

        // Restore original content after printing
        setTimeout(function() {
            document.body.innerHTML = originalContent;
        }, 1000);

    } catch (error) {
        console.error('Print error:', error);
        alert('เกิดข้อผิดพลาดในการพิมพ์: ' + error.message);
    }
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
%>