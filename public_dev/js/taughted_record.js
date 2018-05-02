var taughtedChart = document.getElementById("taughtedChart").getContext('2d');
var myChart = new Chart(taughtedChart, {
    type: 'bar',
    data: {
        labels: ["Quiz1", "Quiz2", "Quiz3", "Quiz4", "Quiz5"],
        datasets: [{
            label: 'Accuracy Rate',
            data: [20, 40, 60, 80, 50],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(255, 159, 64, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(255, 159, 64, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        title: {
            display: true,
        },      
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});

var studentChart = document.getElementById("studentChart").getContext('2d');
var myChart = new Chart(studentChart, {
    type: 'bar',
    data: {
        labels: ["<60%", "60%-80%", ">80%"],
        datasets: [{
            label: 'Number of Students (total: 50)',
            data: [5, 15, 20],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',   
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        title: {
            display: true,
        },      
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});