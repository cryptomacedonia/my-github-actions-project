require('dotenv').config();
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const github = axios.create({
  baseURL: 'https://api.github.com',
  headers: {
    Authorization: `token ${process.env.GITHUB_TOKEN}`,
    Accept: 'application/vnd.github.v3+json',
  },
});

// Trigger a Workflow
// Trigger a Workflow
// Trigger a Workflow
async function triggerWorkflowWithUniqueId(owner, repo, workflow_file_name, uniqueId) {
    try {
        // Trigger the workflow
        await github.post(`/repos/${owner}/${repo}/actions/workflows/${workflow_file_name}/dispatches`, {
            ref: 'main',
            inputs: {
                uniqueId: uniqueId
            }
        });

        // Set the label on the workflow run
        await setWorkflowRunLabel(owner, repo, uniqueId);

        // Fetch the run ID based on the unique identifier
        const runId = await fetchWorkflowRunId(owner, repo, uniqueId);

        if (!runId) {
            throw new Error('Failed to obtain run ID after triggering the workflow.');
        }

        console.log("Workflow triggered successfully with ID:", runId);
        return runId;
    } catch (error) {
        console.error("Error triggering workflow:", error);
        return null;
    }
}

// Set Workflow Run Label
// Set Workflow Run Label
// Set Workflow Run Label
// Set Workflow Run Label
async function setWorkflowRunLabel(owner, repo, uniqueId) {
    try {
        // Fetch the list of workflow runs
        const response = await github.get(`/repos/${owner}/${repo}/actions/runs`, {
            params: { branch: 'main', per_page: 100 }
        });

        const runs = response.data.workflow_runs;

        // Check if runs is an array
        if (!Array.isArray(runs)) {
            throw new Error('Invalid data structure returned by GitHub API.');
        }

        // Find the run with the matching uniqueId
        const matchingRun = runs.find(run => {
            const labels = run.labels.map(label => label.name);
            return labels.includes(uniqueId);
        });

        if (!matchingRun) {
            throw new Error('No matching workflow run found.');
        }

        // Get the run ID
        const runId = matchingRun.id;

        // Use GitHub API to set the label on the workflow run
        await github.post(`/repos/${owner}/${repo}/actions/runs/${runId}/labels`, { labels: [uniqueId] });

        // Set the workflow run ID as an environment variable
        console.log(`uniqueId=${runId}`); // This logs the value of uniqueId to be set as an environment variable
    } catch (error) {
        console.error("Error setting workflow run label:", error);
    }
}


// Add Label to Workflow Run
async function addLabelToWorkflowRun(owner, repo, runId, label) {
    try {
        await github.post(`/repos/${owner}/${repo}/actions/runs/${runId}/labels`, {
            labels: [label]
        });
        console.log("Label added successfully to workflow run:", label);
    } catch (error) {
        console.error("Error adding label to workflow run:", error);
    }
}

// Download Artifact
async function downloadArtifact(owner, repo, artifact_id, outputPath) {
    try {
        const response = await github.get(`/repos/${owner}/${repo}/actions/artifacts/${artifact_id}/zip`, {
            responseType: 'arraybuffer'
        });
        const fs = require('fs');
        fs.writeFileSync(outputPath, response.data);
        console.log("Artifact downloaded successfully.");
    } catch (error) {
        console.error("Error downloading artifact:", error);
    }
}

// Check Workflow Run Status
async function checkWorkflowRunStatus(owner, repo, run_id) {
    try {
        const response = await github.get(`/repos/${owner}/${repo}/actions/runs/${run_id}`);
        return response.data;
    } catch (error) {
        console.error("Error checking workflow run status:", error);
        return null;
    }
}

// Map to store the status of each triggered workflow
const workflowStatusMap = new Map();

async function runWorkflowAndGetArtifact(owner, repo, workflow_file_name, uniqueId, outputPath) {
    try {
        // Trigger the workflow and get the run ID
        const runId = await triggerWorkflowWithUniqueId(owner, repo, workflow_file_name, uniqueId);

        if (!runId) {
            throw new Error('Failed to trigger workflow or obtain run ID.');
        }

        // Add label to the workflow run
        await addLabelToWorkflowRun(owner, repo, runId, `unique-id-${uniqueId}`);

        // Store the status of this workflow as 'pending'
        workflowStatusMap.set(uniqueId, 'pending');

        // Wait for the workflow to complete
        let status = await checkWorkflowRunStatus(owner, repo, runId);
        while (status && status.status !== 'completed') {
            await new Promise(resolve => setTimeout(resolve, 5000)); // Wait for 5 seconds
            status = await checkWorkflowRunStatus(owner, repo, runId);
        }

        // Update the status of this workflow to 'completed'
        workflowStatusMap.set(uniqueId, 'completed');

        // Download the artifact
        await downloadArtifact(owner, repo, runId, outputPath);
    } catch (error) {
        console.error("Error running workflow and getting artifact:", error);
        // Update the status of this workflow to 'failed'
        workflowStatusMap.set(uniqueId, 'failed');
    }
}

// Fetch Latest Workflow Run ID based on Label
async function fetchWorkflowRunId(owner, repo, uniqueId) {
    try {
        // Fetch the list of workflow runs with the specific label
        const response = await github.get(`/repos/${owner}/${repo}/actions/runs`, {
            params: { branch: 'main', per_page: 100, labels: `unique-id-${uniqueId}` }
        });

        const runs = response.data.workflow_runs;

        // Check if runs is an array
        if (!Array.isArray(runs)) {
            throw new Error('Invalid data structure returned by GitHub API.');
        }

        // Find the run with the matching label
        const matchingRun = runs.find(run => run.labels.some(label => label.name === `unique-id-${uniqueId}`));

        if (!matchingRun) {
            throw new Error('No matching workflow run found.');
        }

        return matchingRun.id;
    } catch (error) {
        console.error("Error fetching workflow run ID:", error);
        return null;
    }
}

// Example usage
const owner = 'cryptomacedonia';
const repo = 'my-github-actions-project';
const workflow_file_name = 'build.yml';
const uniqueId = uuidv4();
const outputPath = `./${uniqueId}.zip`;

runWorkflowAndGetArtifact(owner, repo, workflow_file_name, uniqueId, outputPath);
