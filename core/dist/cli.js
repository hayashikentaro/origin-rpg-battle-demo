"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const battle_1 = require("./battle");
function handleRequest(request) {
    try {
        switch (request.operation) {
            case "init":
                return { ok: true, state: (0, battle_1.createInitialState)(request.seed) };
            case "queue_action":
                if (!request.state || !request.actionType) {
                    return { ok: false, error: "Missing state or actionType for queue_action." };
                }
                return { ok: true, state: (0, battle_1.queueAction)(request.state, request.actionType, request.abilityIndex) };
            case "resolve_next":
                if (!request.state) {
                    return { ok: false, error: "Missing state for resolve_next." };
                }
                return { ok: true, state: (0, battle_1.resolveNext)(request.state) };
            case "consume_meat":
                if (!request.state) {
                    return { ok: false, error: "Missing state for consume_meat." };
                }
                return { ok: true, state: (0, battle_1.consumeMeat)(request.state) };
            case "resolve_actor_command":
                if (!request.commandInput) {
                    return { ok: false, error: "Missing commandInput for resolve_actor_command." };
                }
                return { ok: true, actorResolveResult: (0, battle_1.resolveActorCommand)(request.commandInput) };
            default:
                return { ok: false, error: `Unknown operation: ${request.operation}` };
        }
    }
    catch (error) {
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
    const request = JSON.parse(fs.readFileSync(requestPath, "utf8"));
    const response = handleRequest(request);
    fs.writeFileSync(responsePath, JSON.stringify(response, null, 2));
}
main();
