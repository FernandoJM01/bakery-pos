import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { ShiftNoteDto, ShiftsQueryDto } from './dto/shifts-query.dto';
import { ShiftsService } from './shifts.service';

@Controller('shifts')
export class ShiftsController {
  constructor(private readonly shifts: ShiftsService) {}

  @Get()
  @RequirePermission('reports.branch')
  list(@Query() query: ShiftsQueryDto, @CurrentUser() user: AuthenticatedUser) {
    return this.shifts.list(user, query);
  }

  @Get(':shiftId')
  @RequirePermission('reports.branch')
  get(
    @Param('shiftId', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.shifts.get(user, id);
  }

  @Post(':shiftId/notes')
  @HttpCode(200)
  @RequirePermission('reports.branch')
  addNote(
    @Param('shiftId', ParseUUIDPipe) id: string,
    @Body() body: ShiftNoteDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.shifts.addNote(user, id, body.note);
  }
}
