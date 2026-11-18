/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.sql.Timestamp;

/**
 *
 * @author vicen
 */
public class Pedido {

    private int pedidoId;
    private int clienteId;      // FK -> cliente
    private int empleadoId;     // FK -> empleado
    private int estadoPedidoId; // FK -> estado_pedido
    private int prioridadId;    // FK -> prioridad
    private Timestamp fechaPedido;
    private Timestamp fechaEntregaProgramada;

    public Pedido() {
    }

    public int getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(int pedidoId) {
        this.pedidoId = pedidoId;
    }

    public int getClienteId() {
        return clienteId;
    }

    public void setClienteId(int clienteId) {
        this.clienteId = clienteId;
    }

    public int getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(int empleadoId) {
        this.empleadoId = empleadoId;
    }

    public int getEstadoPedidoId() {
        return estadoPedidoId;
    }

    public void setEstadoPedidoId(int estadoPedidoId) {
        this.estadoPedidoId = estadoPedidoId;
    }

    public int getPrioridadId() {
        return prioridadId;
    }

    public void setPrioridadId(int prioridadId) {
        this.prioridadId = prioridadId;
    }

    public Timestamp getFechaPedido() {
        return fechaPedido;
    }

    public void setFechaPedido(Timestamp fechaPedido) {
        this.fechaPedido = fechaPedido;
    }

    public Timestamp getFechaEntregaProgramada() {
        return fechaEntregaProgramada;
    }

    public void setFechaEntregaProgramada(Timestamp fechaEntregaProgramada) {
        this.fechaEntregaProgramada = fechaEntregaProgramada;
    }
}
