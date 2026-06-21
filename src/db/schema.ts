import { pgTable, serial, text } from 'drizzle-orm/pg-core';

export const greeting = pgTable('greeting', {
  id: serial('id').primaryKey(),
  text: text('text').notNull(),
});
