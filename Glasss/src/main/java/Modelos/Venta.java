/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 *
 * @author vicen
 */
public class Venta {

    private int ventaId;
    private Integer empleadoId;    // FK -> empleado
    private Integer clienteId;     // FK -> cliente
    private Integer metodoPagoId;  // FK -> metodo_pago
    private Integer estadoVentaId; // FK -> estado_venta
    private Integer pedidoId;      // FK -> pedido
    private Timestamp fechaVenta;
    private Timestamp fechaEntregaProgramada;
    private BigDecimal total;
    private List<DetalleVenta> detalles; // Relación 1:N
    private List<PagoVenta> pagos;       // Relación 1:N

    public Venta() {
    }

    public int getVentaId() {
        return ventaId;
    }

    public void setVentaId(int ventaId) {
        this.ventaId = ventaId;
    }

    public Integer getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(Integer empleadoId) {
        this.empleadoId = empleadoId;
    }

    public Integer getClienteId() {
        return clienteId;
    }

    public void setClienteId(Integer clienteId) {
        this.clienteId = clienteId;
    }

    public Integer getMetodoPagoId() {
        return metodoPagoId;
    }

    public void setMetodoPagoId(Integer metodoPagoId) {
        this.metodoPagoId = metodoPagoId;
    }

    public Integer getEstadoVentaId() {
        return estadoVentaId;
    }

    public void setEstadoVentaId(Integer estadoVentaId) {
        this.estadoVentaId = estadoVentaId;
    }

    public Integer getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Integer pedidoId) {
        this.pedidoId = pedidoId;
    }

    public Timestamp getFechaVenta() {
        return fechaVenta;
    }

    public void setFechaVenta(Timestamp fechaVenta) {
        this.fechaVenta = fechaVenta;
    }

    public Timestamp getFechaEntregaProgramada() {
        return fechaEntregaProgramada;
    }

    public void setFechaEntregaProgramada(Timestamp fechaEntregaProgramada) {
        this.fechaEntregaProgramada = fechaEntregaProgramada;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public List<DetalleVenta> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetalleVenta> detalles) {
        this.detalles = detalles;
    }

    public List<PagoVenta> getPagos() {
        return pagos;
    }

    public void setPagos(List<PagoVenta> pagos) {
        this.pagos = pagos;
    }
}
