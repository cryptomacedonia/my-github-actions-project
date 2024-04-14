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
async function triggerWorkflowWithUniqueId(owner, repo, workflow_file_name, uniqueId) {
    try {
        // Trigger the workflow
        await github.post(`/repos/${owner}/${repo}/actions/workflows/${workflow_file_name}/dispatches`, {
            ref: 'main',
            inputs: {
                uniqueId: uniqueId
            }
        });

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
        const run_id = await triggerWorkflowWithUniqueId(owner, repo, workflow_file_name, uniqueId);

        if (!run_id) {
            throw new Error('Failed to trigger workflow or obtain run ID.');
        }

        // Store the status of this workflow as 'pending'
        workflowStatusMap.set(uniqueId, 'pending');

        // Wait for the workflow to complete
        let status = await checkWorkflowRunStatus(owner, repo, run_id);
        while (status && status.status !== 'completed') {
            await new Promise(resolve => setTimeout(resolve, 5000)); // Wait for 5 seconds
            status = await checkWorkflowRunStatus(owner, repo, run_id);
        }

        // Update the status of this workflow to 'completed'
        workflowStatusMap.set(uniqueId, 'completed');

        // Download the artifact
        await downloadArtifact(owner, repo, run_id, outputPath);
    } catch (error) {
        console.error("Error running workflow and getting artifact:", error);
        // Update the status of this workflow to 'failed'
        workflowStatusMap.set(uniqueId, 'failed');
    }
}



// Fetch Latest Workflow Run ID
async function fetchWorkflowRunId(owner, repo, uniqueId) {
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

        // Find the run with the matching commit message
        const matchingRun = runs.find(run => run.head_commit.message.includes(`Generated project for uniqueId: ${uniqueId}`));

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
