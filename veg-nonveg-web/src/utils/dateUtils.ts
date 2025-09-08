import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, isToday, addDays, parseISO } from 'date-fns';

export const formatDate = (date: Date | string, pattern: string = 'yyyy-MM-dd'): string => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  return format(dateObj, pattern);
};

export const getMonthDays = (date: Date): Date[] => {
  const start = startOfMonth(date);
  const end = endOfMonth(date);
  return eachDayOfInterval({ start, end });
};

export const getCalendarDays = (date: Date): Date[] => {
  const start = startOfMonth(date);
  const end = endOfMonth(date);
  
  // Get the first day of the week for the month start
  const startDay = start.getDay();
  const calendarStart = addDays(start, -startDay);
  
  // Get the last day of the week for the month end
  const endDay = end.getDay();
  const calendarEnd = addDays(end, 6 - endDay);
  
  return eachDayOfInterval({ start: calendarStart, end: calendarEnd });
};

export const isSameDayHelper = (date1: Date | string, date2: Date | string): boolean => {
  const d1 = typeof date1 === 'string' ? parseISO(date1) : date1;
  const d2 = typeof date2 === 'string' ? parseISO(date2) : date2;
  return isSameDay(d1, d2);
};

export const isTodayHelper = (date: Date | string): boolean => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  return isToday(dateObj);
};

export const getWeekdayName = (weekday: number): string => {
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return weekdays[weekday - 1] || 'Unknown';
};

export const getRelativeTime = (date: Date | string): string => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  const now = new Date();
  const diffMs = now.getTime() - dateObj.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffMinutes = Math.floor(diffMs / (1000 * 60));
  
  if (diffDays > 0) {
    return `${diffDays} day${diffDays === 1 ? '' : 's'} ago`;
  } else if (diffHours > 0) {
    return `${diffHours} hour${diffHours === 1 ? '' : 's'} ago`;
  } else if (diffMinutes > 0) {
    return `${diffMinutes} minute${diffMinutes === 1 ? '' : 's'} ago`;
  } else {
    return 'Just now';
  }
};

export const getUpcomingDays = (days: number = 7): Date[] => {
  const today = new Date();
  const upcomingDays: Date[] = [];
  
  for (let i = 1; i <= days; i++) {
    upcomingDays.push(addDays(today, i));
  }
  
  return upcomingDays;
};