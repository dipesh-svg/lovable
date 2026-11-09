import type { Transporter } from "nodemailer";
import type { CreateEmailOptions } from "resend";

export interface EmailConfig {
  resendApiKey?: string;
  smtp?: {
    host: string;
    port: number;
    user?: string;
    password?: string;
  };
}
export type ResendEmailOptions = Pick<
  CreateEmailOptions,
  "to" | "subject" | "react" | "html"
>;

export type NodemailerInput = Pick<
  ResendEmailOptions,
  "to" | "subject" | "react"
> & { transporter: Transporter };
