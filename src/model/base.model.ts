import { CreateDateColumn, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

export abstract class Model {
  
  @PrimaryGeneratedColumn()
  id!: number;

  @CreateDateColumn({ name: 'create_date'})
  createDate!: Date;

  @UpdateDateColumn({ name: 'update_date'})
  updateDate!: Date;
}
