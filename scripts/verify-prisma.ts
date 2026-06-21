import 'dotenv/config';
import { prisma } from '../lib/prisma.js';

async function main() {
  const userCount = await prisma.user.count();
  console.log(`✅ Connected. Users in database: ${userCount}`);
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
