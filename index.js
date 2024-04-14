require('dotenv').config();
const axios = require('axios');

const github = axios.create({
  baseURL: 'https://api.github.com',
  headers: {
    Authorization: `token ${process.env.GITHUB_TOKEN}`,
    Accept: 'application/vnd.github.v3+json',
  },
});

async function triggerWorkflow(owner, repo, workflow_id, inputs) {
    const response = await github.post(`/repos/${owner}/${repo}/actions/workflows/${workflow_id}/dispatches`, {
      ref: 'main', // or the branch you want to dispatch on
      inputs: inputs
    });
    return response.data;
  }