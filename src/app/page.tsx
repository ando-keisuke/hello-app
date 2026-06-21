import { db } from '@/db';
import { greeting } from '@/db/schema';
import { sql } from 'drizzle-orm';

export default async function Home() {
  const rows = await db.select().from(greeting).orderBy(sql`RANDOM()`).limit(1);
  const message = rows[0]?.text ?? 'No greetings found.';

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 dark:bg-black">
      <p className="text-3xl font-semibold text-zinc-900 dark:text-zinc-50">
        {message}
      </p>
    </div>
  );
}
