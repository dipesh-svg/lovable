import { Resend } from "resend";
import type { ResendEmailOptions } from "./types";

export default async function sendEmailViaResend(
  resend: Resend,
  options: ResendEmailOptions,
) {
  if (options.react) {
    const { data, error } = await resend!.emails.send({
      from: "Lovable <no-reply@lovable.dev>",
      to: options.to,
      subject: options.subject!,
      react: options.react,
    });
    return { data, error };
  } else if (options.html) {
    const { data, error } = await resend!.emails.send({
      from: "Lovable <no-reply@lovable.dev>",
      to: options.to,
      subject: options.subject!,
      react: options.html,
    });
    return { data, error };
  }
}
