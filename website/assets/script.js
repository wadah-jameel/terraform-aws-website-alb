// Enhanced script with better server info handling
document.addEventListener('DOMContentLoaded', function() {
    // Function to get server information
    async function getServerInfo() {
        try {
            const response = await fetch('/server-info');
            if (response.ok) {
                const data = await response.json();
                updateServerInfo(data);
            } else {
                throw new Error('Failed to fetch server info');
            }
        } catch (error) {
            console.log('Could not fetch server info:', error);
            updateServerInfo({
                instanceId: 'Static Server',
                region: 'AWS',
                availabilityZone: 'Multiple AZs',
                instanceType: 'Load Balanced'
            });
        }
    }

    // Function to update server info in the UI
    function updateServerInfo(data) {
        const serverIdElement = document.getElementById('server-id');
        const regionElement = document.getElementById('region');
        
        if (serverIdElement) {
            serverIdElement.textContent = data.instanceId || 'Unknown';
        }
        
        if (regionElement) {
            regionElement.textContent = `${data.region || 'Unknown'} (${data.availabilityZone || 'Unknown AZ'})`;
        }

        // Add instance type if available
        const instanceTypeElement = document.getElementById('instance-type');
        if (instanceTypeElement && data.instanceType) {
            instanceTypeElement.textContent = data.instanceType;
        }
    }

    // Get server info on load
    getServerInfo();

    // Refresh server info every 30 seconds
    setInterval(getServerInfo, 30000);

    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add a simple load balancer test
    const testButton = document.getElementById('test-load-balancer');
    if (testButton) {
        testButton.addEventListener('click', async function() {
            const results = [];
            const testCount = 5;
            
            for (let i = 0; i < testCount; i++) {
                try {
                    const response = await fetch('/server-info');
                    const data = await response.json();
                    results.push(data.instanceId);
                } catch (error) {
                    results.push('Error');
                }
                await new Promise(resolve => setTimeout(resolve, 500));
            }
            
            const uniqueInstances = [...new Set(results)];
            alert(`Load Balancer Test Results:\nRequests: ${testCount}\nUnique Instances: ${uniqueInstances.length}\nInstances: ${uniqueInstances.join(', ')}`);
        });
    }
});
