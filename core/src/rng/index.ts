export interface SeedCarrier {
  seed: number;
}

const MODULUS = 2147483647;
const MULTIPLIER = 48271;

export function normalizeSeed(seed: number): number {
  let normalized = Math.abs(Math.floor(seed)) % MODULUS;
  if (normalized === 0) {
    normalized = 1;
  }
  return normalized;
}

export function nextFloat(carrier: SeedCarrier): number {
  carrier.seed = (carrier.seed * MULTIPLIER) % MODULUS;
  return carrier.seed / MODULUS;
}

export function nextInt(carrier: SeedCarrier, min: number, max: number): number {
  const roll = nextFloat(carrier);
  return min + Math.floor(roll * (max - min + 1));
}
