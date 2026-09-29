let grafico = null;


async function cargarDashboard() {

    try {

        const respuesta =
            await fetch("/api/almacenamiento");

        const datos =
            await respuesta.json();


        if (!datos.disponible) {

            document.getElementById(
                "estadoGeneral"
            ).innerHTML =
                "<span class='estado-punto'></span> Sin datos";

            return;
        }


        const actual = datos.actual;


        /* MÉTRICAS */

        document.getElementById(
            "biblioteca"
        ).textContent =
            actual.biblioteca.toFixed(2);


        document.getElementById(
            "archivos"
        ).textContent =
            actual.archivos.toLocaleString("es-CL");


        document.getElementById(
            "libre"
        ).textContent =
            actual.libre.toFixed(2);


        document.getElementById(
            "estado"
        ).textContent =
            actual.estado;


        document.getElementById(
            "ultimaMedicion"
        ).textContent =
            actual.fecha;


        document.getElementById(
            "cantidadMediciones"
        ).textContent =
            datos.historial.length;


        /* ESTADO */

        const estado =
            document.getElementById("estado");


        estado.className = "";


        if (actual.estado === "SALUDABLE")
            estado.classList.add("saludable");


        if (actual.estado === "ADVERTENCIA")
            estado.classList.add("advertencia");


        if (actual.estado === "CRITICO")
            estado.classList.add("critico");


        document.getElementById(
            "estadoGeneral"
        ).innerHTML =
            "<span class='estado-punto'></span>" +
            actual.estado;


        /* DISCO */

        const total =
            actual.usado + actual.libre;


        const porcentaje =
            total > 0
                ? (actual.usado / total) * 100
                : 0;


        document.getElementById(
            "porcentajeDisco"
        ).textContent =
            porcentaje.toFixed(1) + "%";


        document.getElementById(
            "barraDisco"
        ).style.width =
            porcentaje + "%";


        document.getElementById(
            "usado"
        ).textContent =
            actual.usado.toFixed(2) + " GB";


        document.getElementById(
            "libreDetalle"
        ).textContent =
            actual.libre.toFixed(2) + " GB";


        crearGrafico(datos.historial);

    }

    catch (error) {

        console.error(error);

        document.getElementById(
            "estadoGeneral"
        ).textContent =
            "Error de conexión";

    }

}


function crearGrafico(historial) {

    const etiquetas =
        historial.map(item => item.fecha);


    const valores =
        historial.map(item => item.biblioteca);


    const canvas =
        document.getElementById("grafico");


    if (grafico)
        grafico.destroy();


    grafico =
        new Chart(canvas, {

            type: "line",

            data: {

                labels: etiquetas,

                datasets: [{

                    data: valores,

                    borderColor:
                        "rgba(230,230,235,0.85)",

                    backgroundColor:
                        "rgba(255,255,255,0.025)",

                    borderWidth: 1.5,

                    pointRadius: 2,

                    pointHoverRadius: 5,

                    pointBackgroundColor:
                        "#ffffff",

                    tension: 0.35,

                    fill: true

                }]

            },


            options: {

                responsive: true,

                maintainAspectRatio: false,

                interaction: {
                    intersect: false,
                    mode: "index"
                },


                plugins: {

                    legend: {
                        display: false
                    },

                    tooltip: {

                        backgroundColor:
                            "#151517",

                        borderColor:
                            "rgba(255,255,255,.1)",

                        borderWidth: 1,

                        titleColor:
                            "#aaa",

                        bodyColor:
                            "#fff",

                        displayColors:
                            false,

                        callbacks: {

                            label:
                                context =>
                                    context.parsed.y
                                        .toFixed(2)
                                    + " GB"

                        }

                    }

                },


                scales: {

                    x: {

                        border: {
                            display: false
                        },

                        grid: {
                            display: false
                        },

                        ticks: {

                            color: "#444",

                            maxTicksLimit: 7,

                            font: {
                                size: 9
                            }

                        }

                    },


                    y: {

                        border: {
                            display: false
                        },

                        grid: {

                            color:
                                "rgba(255,255,255,.035)"

                        },

                        ticks: {

                            color: "#444",

                            font: {
                                size: 9
                            },

                            callback:
                                value =>
                                    value + " GB"

                        }

                    }

                }

            }

        });

}


cargarDashboard();