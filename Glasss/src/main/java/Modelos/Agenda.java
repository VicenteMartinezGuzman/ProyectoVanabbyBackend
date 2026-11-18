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
public class Agenda {

    private int agendaId;
    private Integer ventaId;               // FK -> venta
    private Timestamp fechaProgramada;
    private Integer responsableEmpleadoId; // FK -> empleado
    private Integer estadoAgendaId;        // FK -> estado_agenda
    private String notas;

    public Agenda() {
    }

    public int getAgendaId() {
        return agendaId;
    }

    public void setAgendaId(int agendaId) {
        this.agendaId = agendaId;
    }

    public Integer getVentaId() {
        return ventaId;
    }

    public void setVentaId(Integer ventaId) {
        this.ventaId = ventaId;
    }

    public Timestamp getFechaProgramada() {
        return fechaProgramada;
    }

    public void setFechaProgramada(Timestamp fechaProgramada) {
        this.fechaProgramada = fechaProgramada;
    }

    public Integer getResponsableEmpleadoId() {
        return responsableEmpleadoId;
    }

    public void setResponsableEmpleadoId(Integer responsableEmpleadoId) {
        this.responsableEmpleadoId = responsableEmpleadoId;
    }

    public Integer getEstadoAgendaId() {
        return estadoAgendaId;
    }

    public void setEstadoAgendaId(Integer estadoAgendaId) {
        this.estadoAgendaId = estadoAgendaId;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }
}
