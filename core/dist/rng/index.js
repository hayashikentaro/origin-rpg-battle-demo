"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.nextInt = exports.nextFloat = exports.normalizeSeed = void 0;
const MODULUS = 2147483647;
const MULTIPLIER = 48271;
function normalizeSeed(seed) {
    let normalized = Math.abs(Math.floor(seed)) % MODULUS;
    if (normalized === 0) {
        normalized = 1;
    }
    return normalized;
}
exports.normalizeSeed = normalizeSeed;
function nextFloat(carrier) {
    carrier.seed = (carrier.seed * MULTIPLIER) % MODULUS;
    return carrier.seed / MODULUS;
}
exports.nextFloat = nextFloat;
function nextInt(carrier, min, max) {
    const roll = nextFloat(carrier);
    return min + Math.floor(roll * (max - min + 1));
}
exports.nextInt = nextInt;
