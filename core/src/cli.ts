declare const require: any;
declare const process: any;

const fs = require("fs");

import { consumeMeat, createInitialState, queueAction, resolveActorCommand, resolveNext } from "./battle";
import { CoreRequest, CoreResponse } from "./shared/types";

function handleRequest(request: CoreRequest): CoreResponse {
  try {
    switch (request.operation) {
      case "init":
        return { ok: true, state: createInitialState(request.seed) };
      case "queue_action":
        if (!request.state || !request.actionType) {
          return { ok: false, error: "Missing state or actionType for queue_action." };
        }
        return { ok: true, state: queueAction(request.state, request.actionType, request.abilityIndex) };
      case "resolve_next":
        if (!request.state) {
          return { ok: false, error: "Missing state for resolve_next." };
        }
        return { ok: true, state: resolveNext(request.state) };
      case "consume_meat":
        if (!request.state) {
          return { ok: false, error: "Missing state for consume_meat." };
        }
        return { ok: true, state: consumeMeat(request.state) };
      case "resolve_actor_command":
        if (!request.commandInput) {
          return { ok: false, error: "Missing commandInput for resolve_actor_command." };
        }
        return { ok: true, actorResolveResult: resolveActorCommand(request.commandInput) };
      default:
        return { ok: false, error: `Unknown operation: ${request.operation}` };
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return { ok: false, error: message };
  }
}

function main() {
  const requestPath = process.argv[2];
  const responsePath = process.argv[3];
  if (!requestPath || !responsePath) {
    throw new Error("Usage: node cli.js <request-path> <response-path>");
  }
  const request = JSON.parse(fs.readFileSync(requestPath, "utf8")) as CoreRequest;
  const response = handleRequest(request);
  fs.writeFileSync(responsePath, JSON.stringify(response, null, 2));
}

main();
