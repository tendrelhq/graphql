import type { Response } from "express";

const ErrorCode = {
  "bad request": 400,
  "not found": 404,
} as const;
type ErrorCode = keyof typeof ErrorCode;

export class RuntimeError extends Error {
  constructor(
    readonly type: "user" | "system",
    readonly code: ErrorCode,
    message: string,
    cause?: Error,
  ) {
    super(message, cause);
  }

  putInto(res: Response) {
    return res.status(ErrorCode[this.code]).json({ message: this.message });
  }
}

export class NotFoundError extends RuntimeError {
  constructor(what: string, kind: string, cause?: Error) {
    super("user", "not found", `${what} (${kind})`, cause);
  }
}
