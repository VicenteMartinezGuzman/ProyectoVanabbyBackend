/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

/**
 *
 * @author vicen
 */
public class PasoReceta {

    private int pasoId;
    private Integer recetaId; // FK -> receta
    private Integer numeroPaso;
    private String descripcion;

    public PasoReceta() {
    }

    public int getPasoId() {
        return pasoId;
    }

    public void setPasoId(int pasoId) {
        this.pasoId = pasoId;
    }

    public Integer getRecetaId() {
        return recetaId;
    }

    public void setRecetaId(Integer recetaId) {
        this.recetaId = recetaId;
    }

    public Integer getNumeroPaso() {
        return numeroPaso;
    }

    public void setNumeroPaso(Integer numeroPaso) {
        this.numeroPaso = numeroPaso;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
