export const sum = (numbers: Array<number>): number => {
  return numbers.reduce((pre, cur) => pre + cur, 0)
}
