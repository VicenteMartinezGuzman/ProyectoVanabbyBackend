/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

/**
 *
 * @author vicen
 */
import java.sql.Timestamp;

public class Bloqueo {

    private int bloqueoId;
    private Integer empleadoId; // FK -> empleado
    private Integer clienteId;  // FK -> cliente
    private Timestamp fechaBloqueo;
    private int intentosAcumulados;
    private Integer desbloqueadoPorEmpleadoId; // FK -> empleado
    private Timestamp fechaDesbloqueo;
    private String motivo;

    public Bloqueo() {
    }

    public int getBloqueoId() {
        return bloqueoId;
    }

    public void setBloqueoId(int bloqueoId) {
        this.bloqueoId = bloqueoId;
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

    public Timestamp getFechaBloqueo() {
        return fechaBloqueo;
    }

    public void setFechaBloqueo(Timestamp fechaBloqueo) {
        this.fechaBloqueo = fechaBloqueo;
    }

    public int getIntentosAcumulados() {
        return intentosAcumulados;
    }

    public void setIntentosAcumulados(int intentosAcumulados) {
        this.intentosAcumulados = intentosAcumulados;
    }

    public Integer getDesbloqueadoPorEmpleadoId() {
        return desbloqueadoPorEmpleadoId;
    }

    public void setDesbloqueadoPorEmpleadoId(Integer desbloqueadoPorEmpleadoId) {
        this.desbloqueadoPorEmpleadoId = desbloqueadoPorEmpleadoId;
    }

    public Timestamp getFechaDesbloqueo() {
        return fechaDesbloqueo;
    }

    public void setFechaDesbloqueo(Timestamp fechaDesbloqueo) {
        this.fechaDesbloqueo = fechaDesbloqueo;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }
}
