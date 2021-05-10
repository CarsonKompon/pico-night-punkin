pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--week 7 source code
--top secret hush hush

function _init()
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 3
	cartdata("ckcw_fnfp8")
	menuitem(1,"back to title",function() dset(60,1) load("fnf-select.p8") end)
	function toggle_downscroll()
		if downscroll == 0 then
			downscroll = 1
			menuitem(2,"downscroll: on",toggle_downscroll)
		else
			downscroll = 0
			menuitem(2,"downscroll: off",toggle_downscroll)
		end
		dset(50,downscroll)
	end
	downscroll = dget(50)
	if downscroll == 0 then
		menuitem(2,"downscroll: off",toggle_downscroll)
	else
		menuitem(2,"downscroll: on",toggle_downscroll)
	end
	difficulty = dget(55)
	local _potseed = dget(54)
	if difficulty == 2 and _potseed ~= 0 then
		seed = _potseed
		baseseed = seed
	end
	fadein = 15
	fadeout = -1
	game_init() --its that easy???
	synctime = 318
end

function _update60()
	if(fadein > 0) fadein-=0.5
	if fadeout > 0 then
		fadeout-=0.5
		if fadeout == 0 then
			if(score > dget(songid) and hp > 0) dset(songid,score)
			dset(60,1)
			load("fnf-select.p8")
		end
	end
	game_update() --yes!!!!
	--if(stat(26) > synctime) synctime = stat(26)
end

function _draw()
	game_draw() --fuck no!!!!
	if(fadein > 0) fadeall(ceil(fadein))
	if(fadeout > -1) fadeall(15-ceil(fadeout))
	--print(synctime,30,30,7)
end
-->8
--game controller
function game_init()
	camx = 0
	camy = -10
	camxto = 0
	camyto = 0
	camlerp = 0.0325
	laststep = 0
	step = 0
	score = 0
	hp = 250
	maxhp = 500
	press = {false,false,false,false}
	currentpattern=-1
	
	leftmap = {}
	rightmap = {}
	lastmap = -1
	if difficulty == 0 then
		init_beatmap()
	else
		init_beatmap_hard()
	end
	
	arrows_init()
	parts_init()
	popups_init()
	speedlines = {}
	
	chars_init()
	
	move_cam(0,-2)
end

function game_update()
	laststep = step
	step+=1
	--step = stat(26) + (stat(24)*  350)
	--if(stat(26)+(stat(24)*350) >= 350) step-=1
	if(step < 0) move_cam(0,-4)
	
	if stat(24) ~= currentpattern then
		currentpattern = stat(24)
		step = ((((32*currentpattern)+1)/32)*(synctime/2))
	end
	
	--save seed to clipboard
	if difficulty == 2 and btnp(🅾️,1) then
		printh(baseseed,"@clip")
	end
	
	if flr(step)%3 == 0 then
		add(speedlines,{
		x=128,
		y=flr(rnd(128)),
		len=12+flr(rnd(64)),
		spd=12+rnd(6)
		})
	end
	
	for _sl in all(speedlines) do
		_sl.x -= _sl.spd 
		if _sl.x+_sl.len <= 0 then
			del(speedlines,_sl)
		end
	end
	
	if abs(step-laststep) < 10 then
		--left side
		if #leftmap > 0 then
			if step >= (((leftmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #leftmap[1] > 3 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], leftmap[1][4])
				elseif #leftmap[1] > 2 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], false)
				else
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], 0, false)
				end
				deli(leftmap,1)
			end
		end
		
		--right side
		if #rightmap > 0 then
			if step >= (((rightmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #rightmap[1] > 2 then
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], rightmap[1][3])
				else
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], 0)
				end
				deli(rightmap,1)
			end
		end
	end
	
	if hp > 0 then
		chars_update()
		arrows_update()
		parts_update()
		popups_update()
	end
	
	--dead
	if hp <= 0 then
		dset(62,chars[2].x-camx)
		dset(63,chars[2].y-camy)
		dset(61,songid)
		load("fnf-gameover.p8")
	end
	
	if stat(24)==-1 and fadeout == -1 then
		fadeout = 15
	end
	
	--center camera on duet (928)
	local _duetstart = ((928+1)/32)*(synctime/2)
	local _duetlength = ((127+1)/32)*(synctime/2)
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(0,-2)
	end
	
	--center camera on duet (1120)
	local _duetstart = ((1120+1)/32)*(synctime/2)
	local _duetlength = ((61+1)/32)*(synctime/2)
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(0,-2)
	end
	
	camx = lerp(camx,camxto,camlerp)
	camy = lerp(camy,camyto,camlerp)
	camera(camx,camy)
	
end

--move camera--
function move_cam(_x,_y,_lerp)
	_lerp = _lerp or camlerp
	camxto = _x
	camyto = _y
	camlerp = _lerp
end

-- get inputs ⬅️⬇️⬆️➡️ --
function get_inputs()
	lastpress = {press[1],press[2],press[3],press[4]}
	press = {false,false,false,false}
	if(btn(⬅️) or btn(⬅️,1)) press[1] = true
	if(btn(⬇️) or btn(⬇️,1)) press[2] = true
	if(btn(⬆️) or btn(⬆️,1) or btn(🅾️)) press[3] = true
	if(btn(➡️) or btn(➡️,1) or btn(❎)) press[4] = true
end

function game_draw()
	cls(12)
	pal()
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	
	for _sl in all(speedlines) do
		line(128-_sl.x,_sl.y,128-_sl.x-_sl.len,_sl.y,7)
	end
	
	--ground
	circfill(lx+63,ly+481,400,13)
	fillp(▒)
	circfill(lx+63,ly+485,400,5)
	fillp(█)
	circfill(lx+63,ly+485+4,400,5)
	
	color(7)
	--print(step, 0, 0)
	--print(score,0, 8)
	--print(step-laststep,32,0)
	
	
	if hp > 0 then
		chars_draw()
		local _nh = 128-noteheight
		
		--left side
		if downscroll == 0 then
			sspr(117,0,11,12,camx+4+(14*0),camy+_nh,11,12,true)
			sspr(116,12,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
			sspr(116,12,12,11,camx+4+(14*2),camy+_nh,12,11)
			sspr(117,0,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(117,0,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(116,12,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(116,12,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(117,0,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
			pal()
		end
		
		--particles
		parts_draw()
		
		--popups
		popups_draw()
		
		--arrows
		if downscroll == 0 then
			arrows_draw()
		else
			arrows_draw_downscroll()
		end
		
		--health bar
		if downscroll == 0 then
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+127-8,camx+63-42+84,camy+127-2,3)
			rectfill(camx+63-42+1,camy+127-7,camx+63-42+84-1,camy+127-3,11)
			rectfill(camx+63-42,camy+127-8,_xx,camy+127-2,2)
			rectfill(camx+63-42+1,camy+127-7,_xx,camy+127-3,8)
			palt(14,true)
			palt(0,false)
			sspr(115,23,13,9,_xx+3,camy+127-9)
			sspr(83,39,13,12,_xx-3-11,camy+127-12)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(14,true)
			palt(0,false)
			sspr(115,23,13,9,_xx+3,camy+128-9-(127-9))
			sspr(83,39,13,12,_xx-3-11,camy+128-15-(127-12))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,0)
		else
			print(tostr(score),camx+64-#tostr(score)*2,camy+128-8,7)
		end
		
	else
		--dead
		rectfill(camx,camy,camx+128,camy+128,0)
		palt(0,false)
		palt(3,true)
		fade(7)
		sspr(28,30,27,27,chars[2].x-flr(27/2),chars[2].y-27)
		pal()
	end
	pal()
end

function dir_to_ang(_dir)
	if(_dir == 0) return 180
	if(_dir == 1) return 90
	if(_dir == 2) return 270
	return 0
end

--linear interpolation
function lerp(pos,tar,perc)
 return pos+((tar-pos)*perc)
end

-- fade to black
local fadetable0={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
{2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
{3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
{4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
{5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
{6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
{7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
{8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
{9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
{10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
{11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
{12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
{13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
{14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
{15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0)
		else
			pal(c,fadetable0[c+1][flr(i+1)])
		end
	end
end

function fadeall(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0,1)
		else
			pal(c,fadetable0[c+1][flr(i+1)],1)
		end
	end
end

function spr_r(sx,sy,x,y,a,w,h)
 sw=(w or 8)
 sh=(h or 8)
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    pset(x+ix,y+iy,sget(sx+xx,sy+yy))
   end
  end
 end
end

--choose random array
function choose(t)
	return t[flr(rnd(#t))+1]
end
-->8
--beatmap
function init_beatmap_hard()
	
	--mom
	map_add(leftmap,32,"0,1:4,1:8,1:9,0:10,3:11,2,3:14,1:18,1:22,1:24,3:26,1:28,0:30,1")
	map_add(leftmap,64,"0,1:4,1:8,1:9,0:10,3:11,2,3:14,1:18,1:22,1:24,3:26,1:28,2:29,3:30,0")
	
	--boyfriend
	map_add(rightmap,64+32,"0,1:4,1:8,1:9,0:10,3:11,2,3:14,1:18,1:22,1:24,3:26,1:28,0:30,1")
	map_add(rightmap,64+64,"0,1:4,1:8,1:9,0:10,3:11,2,3:14,1:18,1:22,1:24,3:26,1:28,2:29,3:30,0")
	
	--mom
	map_add(leftmap,128+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,3:51,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,192+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,3:51,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,256+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:58,3:59,1:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,320+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:58,3:59,1:60,0:62,3")
	
	--mom
	map_add(leftmap,384+32,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:29,3:30,1,2:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	
	--boyfriend
	map_add(rightmap,448+32,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:29,3:30,1,2:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	
	--mom
	map_add(leftmap,512+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,576+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,640+32,"0,0:2,1:4,3:6,1:8,3:10,1:12,0:13,3:14,2")
	map_add(leftmap,640+32+16,"0,0:2,1:4,3:6,1:8,3:10,1:12,0:13,3:14,2")
	map_add(leftmap,640+32+32,"0,2:1,3:2,1:4,2:5,3:6,1:8,2:9,3:10,1:12,2:13,3:14,1")
	map_add(leftmap,640+32+48,"0,2:1,3:2,1:4,2:5,3:6,1:8,2:9,3:10,1:12,2:13,3:14,1")
	
	--boyfriend
	map_add(rightmap,704+32,"0,0:2,1:4,3:6,1:8,3:10,1:12,0:13,3:14,2")
	map_add(rightmap,704+32+16,"0,0:2,1:4,3:6,1:8,3:10,1:12,0:13,3:14,2")
	map_add(rightmap,704+32+32,"0,2:1,3:2,1:4,2:5,3:6,1:8,2:9,3:10,1:12,2:13,3:14,1")
	map_add(rightmap,704+32+48,"0,2:1,3:2,1:4,2:5,3:6,1:8,2:9,3:10,1:12,2:13,3:14,1")
	
	--mom
	map_add(leftmap,768+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3:53,1:54,0:56,1:58,3:59,1:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,832+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3:53,1:54,0:56,1:58,3:59,1:60,0:62,3")
	
	--!!duet!!
	map_add(leftmap,896+32,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:29,3:30,1,2:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	map_add(rightmap,896+32,"0,2,9:12,0:14,2:16,2,3:20,3:24,1,3:28,3:29,0:30,1,2:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	map_add(leftmap,960+32,"0,0,4:4,1,4:8,3,4:12,1,4:16,2,4:20,1,4:24,3,4:28,1,4:32,1,4:36,3,4:40,0,4:44,3,4:48,2,4:52,3,4:56,2,4:60,1,4")
	map_add(rightmap,960+32,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:29,3:30,1,2:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	
	--mom
	map_add(leftmap,1024+32,"0,1:4,1:8,1:10,0:11,3:12,2:14,1:18,1:22,1:26,3:27,0:28,2,4:32,1:36,1:40,1:42,3:43,0:44,2:46,1:48,0:50,1:52,2:54,1:56,3:58,1:59,2:60,3:62,0")
	--micro duet
	map_add(leftmap,1088+32,"0,1:4,1:8,1:10,0:11,3:12,2:14,1:18,1:22,1:26,3:27,0:28,2,4:32,1:36,1:40,1:42,3:43,0:44,2:46,1:48,0:50,1:52,2:54,1:56,3:58,1:59,2:60,3:62,0")
	map_add(rightmap,1088+32,"0,1:4,1:8,1:10,0:11,3:12,2:14,1:18,1:22,1:26,3:27,0:28,2,4:32,1:36,1:40,1:42,3:43,0:44,2:46,1:48,0:50,1:52,2:54,1:56,3:58,1:59,2:60,3:62,0")
	
	--mom
	map_add(leftmap,1152+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,3:51,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,1216+32,"0,2,9:12,1:14,1:15,3,5:22,3:23,2,3:26,0:30,1,4:34,0:35,3:36,1,4:40,2,4:44,0:48,3:50,3:51,2:52,0:54,1:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,1280+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:58,3:59,1:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,1344+32,"0,1:1,3:2,0:3,3:6,3:8,1:11,1:14,0:18,2:20,3,2:22,1:24,1:27,1:30,3:33,1:34,3:35,0:36,3:39,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:58,3:59,1:60,0:62,3:64,2,11")
	
	
	
	music(0)
end

function init_beatmap()
	
	--mom
	map_add(leftmap,32*1,"0,1:4,1:8,1:11,2,3:14,1:18,1:22,1:24,3:26,1:28,0:30,1:32,1:36,1:40,1:43,2,3:46,1:50,1:54,1:56,3:58,1:60,2:62,0")
	
	--boyfriend
	map_add(rightmap,32*3,"0,1:4,1:8,1:11,2,3:14,1:18,1:22,1:24,3:26,1:28,0:30,1:32,1:36,1:40,1:43,2,3:46,1:50,1:54,1:56,3:58,1:60,2:62,0")
	
	--mom
	map_add(leftmap,32*5,"0,2,9:12,1:14,3,8:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,32*7,"0,2,9:12,1:14,3,8:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,32*9,"0,1:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,32*11,"0,1:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3")
	
	--mom
	map_add(leftmap,32*13,"0,2,9:12,1:16,0,3:20,1:24,2,3:28,0:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	
	--boyfriend
	map_add(rightmap,32*15,"0,2,9:12,1:16,0,3:20,1:24,2,3:28,0:32,2:34,0:36,3:38,0:40,2:42,3:44,0:46,3:48,2:50,3:52,2:54,0:56,2,4:60,1,4")
	
	--mom
	map_add(leftmap,32*17,"0,2,9:12,1:14,3,7:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,32*19,"0,2,9:12,1:14,3,7:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,32*21,"0,0:2,1:4,3:6,0:8,1:10,3:12,0:14,1:16,0:18,1:20,3:22,0:24,1:26,3:28,0:30,1:32,2:33,3:36,2:37,3:40,2:41,3:44,2:45,3:48,2:49,3:52,2:53,3:56,2:57,3:60,2:61,3")
	
	--boyfriend
	map_add(rightmap,32*23,"0,0:2,1:4,3:6,0:8,1:10,3:12,0:14,1:16,0:18,1:20,3:22,0:24,1:26,3:28,0:30,1:32,2:33,3:36,2:37,3:40,2:41,3:44,2:45,3:48,2:49,3:52,2:53,3:56,2:57,3:60,2:61,3")
	
	--mom
	map_add(leftmap,32*25,"0,2:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,32*27,"0,2:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3")
	
	--duet
	map_add(leftmap,32*29,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:32,2:36,3:38,0:42,3:44,0:46,3:48,2:52,2:54,0:56,2,4:60,1,4")
	map_add(rightmap,32*29,"0,2,9:12,0:14,2:16,2,3:20,3:24,1,3:28,3:32,2:36,3:38,0:42,3:44,0:46,3:48,2:52,2:54,0:56,2,4:60,1,4")
	map_add(leftmap,32*31,"0,0,4:4,1,4:8,3,4:12,1,4:16,2,4:20,1,4:24,3,4:28,1,4:32,1,4:36,3,4:40,0,4:44,3,4:48,2,4:52,3,4:56,2,4:60,1,4")
	map_add(rightmap,32*31,"0,2,9:12,1:14,3:16,0,3:20,1:24,2,3:28,0:32,2:36,3:38,0:42,3:44,0:46,3:48,2:52,2:54,0:56,2,4:60,1,4")
	
	--mom
	map_add(leftmap,32*33,"0,1:4,1:8,1:12,2:14,1:18,1:22,1:26,3:28,2,4:32,1:36,1:40,1:44,2:46,1:50,1:54,1:56,3:58,1:60,3:62,0")
	
	--microduet
	map_add(leftmap,32*35,"0,1:4,1:8,1:12,2:14,1:18,1:22,1:26,3:28,2,4:32,1:36,1:40,1:44,2:46,1:50,1:54,1:56,3:58,1:60,3:62,0")
	map_add(rightmap,32*35,"0,1:4,1:8,1:12,2:14,1:18,1:22,1:26,3:28,2,4:32,1:36,1:40,1:44,2:46,1:50,1:54,1:56,3:58,1:60,3:62,0")
	
	--mom
	map_add(leftmap,32*37,"0,2,9:12,1:14,3,7:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--boyfriend
	map_add(rightmap,32*39,"0,2,9:12,1:14,3,7:22,2,4:26,0:30,1,4:34,0:36,1,4:40,2,4:44,0:48,3:52,0:56,3:58,2:60,0:62,1")
	
	--mom
	map_add(leftmap,32*41,"0,1:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3")
	
	--boyfriend
	map_add(rightmap,32*43,"0,1:3,3:6,3:8,1:11,1:14,0:18,2:22,1:24,1:27,1:30,3:34,0:36,3:40,1:43,1:46,2,4:50,2:52,3,2:54,1:56,0:60,0:62,3:64,2,11")
	
	
	music(0)
end

function map_add(_map, _off, _s)
	local _m = lastmap
	if(_map == leftmap) _m = 0
	if(_map == rightmap) _m = 1
	if difficulty == 2 and _m ~= lastmap then
		if _m == 1 then
			srand(seed)
		else
			seed += 1
			srand(seed)
		end
		lastmap = _m
	end
	
	lastrandom = -1
	local _ar = split(_s,":")
	for _a in all(_ar) do
		local _beat = split(_a)
		if difficulty == 2 then
			repeat
				_beat[2] = flr(rnd(4))
			until _beat[2] ~= lastrandom or flr(rnd(8)) == 0
			lastrandom = _beat[2]
		end
		_beat[1] += _off
		add(_map,_beat)
	end
end
-->8
--arrows
function arrows_init()
	leftarrows = {}
	rightarrows = {}
	lefttrails = {}
	righttrails = {}
	combo = 0
	noteheight = 116
	notetime = 1*45
	arrowcols = {2,1,3,4}
	lastrandom = -1
end

function arrow_color(_dir)
	if _dir == 0 then
		pal(5,2)
		pal(6,14)
	elseif _dir == 1 then
		pal(5,1)
		pal(6,12)
	elseif _dir == 2 then
		pal(5,3)
		pal(6,11)
	elseif _dir == 3 then
		pal(5,4)
		pal(6,9)
	end
end

function spawn_arrow(_off,_side,_dir,_len,_ugh)
	local _arrow = {x=_dir*14,y=128-(noteheight/notetime),dir=_dir,len=_len,ugh=_ugh}
	
	--local _offset = flr((step - (((_off+1)/32)*(synctime/2))-(notetime)))
	--for i=1,_offset do
	--	_arrow.y -= noteheight/notetime
	--end
	
	if _side == 0 then
		_arrow.x += 4
		add(leftarrows,_arrow)
		if _len > 0 then
			add(lefttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	else
		_arrow.x += 71
		add(rightarrows,_arrow)
		if _len > 0 then
			add(righttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	end
end

function arrows_update()
	
	get_inputs()
	_pressed = {false,false,false,false}
	hashit = false
	
	for _a in all(leftarrows) do
		_a.y -= noteheight/notetime
		if _a.y <= 128-noteheight then
			if _a.ugh then
				char_animate(1,4,true)
			else char_animate(1,_a.dir,true) end
			move_cam(-20,-2)
			poke(0x5f43)
			del(leftarrows,_a)
		end
	end
	
	for _a in all(rightarrows) do
		_a.y -= noteheight/notetime
		--note goes off screen
		if _a.y <= -10 then
			poke(0x5f43,15)
			hp -= 10
			combo = 0
			del(rightarrows,_a)
		end
		--note collision
		if _a.y <= 128-noteheight+15+4 and _a.y >= 128-noteheight-10-8 then
			move_cam(20,0)
			--note hit
			if press[_a.dir+1] and not hashit and not lastpress[_a.dir+1] then
			--if _a.y <= 128-noteheight+2 then
				hashit=true
				poke(0x5f43)
				
				--animate char
				char_animate(2,_a.dir,true)
				
				create_popup(65,42,choose(split"gOOD!,sICK!!"))
				combo += 1
				if(combo >= 10) create_popup(65,50,"combo " .. tostr(combo))
				
				_pressed[_a.dir+1] = true
				--score += ceil(200*(1-abs(_a.y-(128-noteheight))/7))
				score += 20
				hp += 10
				hp = min(maxhp,hp)
				fx_hit(_a.x+3,_a.y+3,arrowcols[_a.dir+1])
				del(rightarrows,_a)
			end
		end
	end
	
	for _t in all(lefttrails) do
		_t.y -= noteheight/notetime
		
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			if(step%6 == 0) char_animate(1,_t.dir,true)
		end
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(lefttrails,_t)
	end
	
	for _t in all(righttrails) do
		_t.y -= noteheight/notetime
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(righttrails,_t)
		
		--trail collision
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			--hold button
			if press[_t.dir+1] then
			--if true then
				--score += 2
				if(step%6 == 0) char_animate(2,_t.dir,true)
				hp += 1
				hp = min(maxhp,hp)
				spawn_part(_t.x+3,128-noteheight+7,rnd(),1,0.25,0.25,0.1,0.25,arrowcols[_t.dir+1])
			end
		end
		
	end
	
	--pressing when no note is there
	for i=1,4 do
		if press[i] and not lastpress[i] and not _pressed[i] then
			score -= 1
			--animate char
			char_animate(2,i-1,false)
			
			create_popup(65,42,choose(split"bAD,sHIT"))
			hp -= 10
			combo = 0
			
			sfx(1,3)
			poke(0x5f43)
		end
	end
	
end

function arrows_draw()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end

function arrows_draw_downscroll()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end
-->8
--particles
function parts_init()
	parts = {}
end

function fx_hit(_x,_y,_col)
	for i=0,3 do
		spawn_part(_x,_y,(i/4)+0.125,2,0.15,0.125,0.015,0.0675,_col)
	end
end

function spawn_part(_x,_y,_dir,_spd,_fric,_size,_growth,_fade,_col)
	if downscroll > 0 then
		_y = 128 - _y
	end
	add(parts,{
	x=camx+_x,
	y=camy+_y,
	dir=_dir,
	spd=_spd,
	fric=_fric,
	r=_size,
	growth=_growth,
	growthspd=_growth,
	fadeam=_fade,
	fade=0,
	col=_col,
	hs=sin(_dir)*_spd,
	vs=cos(_dir)*_spd,
	lx=_x,
	ly=_y
	})
end

function parts_update()
	for _p in all(parts) do
		if(abs(_p.hs) > 0) _p.hs -= _p.fric*sgn(_p.hs)
		if(abs(_p.vs) > 0) _p.vs -= _p.fric*sgn(_p.vs)
		_p.lx = _p.x
		_p.ly = _p.y
		_p.x += _p.hs
		_p.y += _p.vs
		_p.growthspd += _p.growth
		_p.r += _p.growthspd
		_p.fade += _p.fadeam
		if(_p.fade >= 1 or _p.r <= 0) del(parts,_p)
	end
end

function parts_draw()
	for _p in all(parts) do
		if(_p.fade >= 0.6) fillp(▒)
		if(_p.fade >= 0.85) fillp(░)
		circfill(_p.lx,_p.ly,_p.r,_p.col)
		circfill(_p.x,_p.y,_p.r,_p.col)
		fillp(█)
	end
end
-->8
--characters
function chars_init()
	chars={
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=28,y=102,sx=28,sy=102,hurt=false,rest=0},
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=100,y=102,sx=100,sy=102,hurt=false,rest=0},
		{spx=55,spy=0,spw=29,sph=45,x=64,y=64}
	}
end

function char_animate(_chr,_dir,_good)
	if _chr == 1 then
		if _dir == 0 then
			chars[_chr].spx = 36
			chars[_chr].spy = 73
			chars[_chr].spw = 33
			chars[_chr].sph = 55
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 101
			chars[_chr].spy = 41
			chars[_chr].spw = 27
			chars[_chr].sph = 39
			chars[_chr].y = chars[_chr].sy + 3
		elseif _dir == 2 then
			chars[_chr].spx = 70
			chars[_chr].spy = 74
			chars[_chr].spw = 28
			chars[_chr].sph = 54
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 0
			chars[_chr].spy = 77
			chars[_chr].spw = 36
			chars[_chr].sph = 51
			chars[_chr].x = chars[_chr].sx + 4
		elseif _dir == 4 then
			chars[_chr].spx = 99
			chars[_chr].spy = 76
			chars[_chr].spw = 26
			chars[_chr].sph = 27
			chars[_chr].y = chars[_chr].sy
			chars[_chr].x = chars[_chr].sx+2
		end
	else
		if _dir == 0 then
			chars[_chr].spx = 0
			chars[_chr].spy = 55
			chars[_chr].spw = 27
			chars[_chr].sph = 22
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 28
			chars[_chr].spy = 23
			chars[_chr].spw = 27
			chars[_chr].sph = 20
			chars[_chr].y = chars[_chr].sy + 4
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 29
			chars[_chr].spw = 28
			chars[_chr].sph = 26
			chars[_chr].y = chars[_chr].sy - 4
		elseif _dir == 3 then
			chars[_chr].spx = 28
			chars[_chr].spy = 44
			chars[_chr].spw = 28
			chars[_chr].sph = 29
			chars[_chr].x = chars[_chr].sx + 4
		end
	end
	
	chars[_chr].sp = _dir
	chars[_chr].hurt = not _good
	chars[_chr].rest = 30
end

function chars_update()
	for i=1,2 do
		chars[i].x = lerp(chars[i].x,chars[i].sx,0.125)
		chars[i].y = lerp(chars[i].y,chars[i].sy,0.125)
		if chars[i].rest > 0 then
			chars[i].rest -= 1
			if chars[i].rest == 0 then
				chars[i].sp = 0
				chars[i].hurt = false
			end
		end
		if chars[i].rest == 0 then
			if i == 1 then
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].sp = -1
					chars[i].spx=64
					chars[i].spy=96
					chars[i].spw=30
					chars[i].sph=32
				else
					chars[i].sp = -2
					chars[i].spx=59
					chars[i].spy=62
					chars[i].spw=31
					chars[i].sph=33
				end
			else
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].sp=-1
					chars[i].spx=0
					chars[i].spy=0
					chars[i].spw=28
					chars[i].sph=21
				else
					chars[i].sp=-2
					chars[i].spx=28
					chars[i].spy=0
					chars[i].spw=27
					chars[i].sph=23
				end
			end
		end
	end
	
	--girlfriend
	--[[
	if flr(step/(synctime/8)) % 2 == 1 then
		chars[3].spx=85
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=47
	else
		chars[3].spx=55
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=46
	end
	]]--
	
end

function chars_draw()
	--girlfriend
	palt(0,false)
	palt(10,true)
	local lx = camx/4
	local ly = 0
	sspr(98,103,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22)
	if flr(step/(synctime/8)) % 2 == 1 then
		sspr(98,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(98,117,15,11,lx+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(55,0,13,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(55,0,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(77,51,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	else
		sspr(113,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(113,117,15,11,lx+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(68,0,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(68,0,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	pal()
	
	for i=1,2 do
		palt(0,false)
		palt(3,true)
		local _c = chars[i]
		if(_c.hurt) fade(7)
		--if i == 1 then sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph,true)
		if i == 1 then
			palt(3,false)
			palt(11,true)
			if _c.sp == -1 then
				sspr(55,15,30,24,_c.x-flr(_c.spw/2),_c.y-53)
				sspr(56,39,21,15,_c.x-flr(_c.spw/2)+1,_c.y-53+24)
				sspr(56,55,19,14,_c.x-flr(_c.spw/2)+1,_c.y-53+29+10)
			elseif _c.sp == -2 then
				sspr(85,0,30,39,_c.x-flr(_c.spw/2),_c.y-53)
				sspr(56,55,19,14,_c.x-flr(_c.spw/2)+1,_c.y-53+29+10)
			else
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			end
		else
			if _c.sp == 3 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				if(_c.sp == -1)sspr(0,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp == -2) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp >= 0) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph-7,_c.spw,_c.sph)
			end
		end
		pal()
	end

end
-->8
--popups system
function popups_init()
	popups={}
end

function create_popup(_x,_y,_txt)
	add(popups,{
	x=_x,y=_y,sy=_y,txt=_txt,fade=0
	})
end

function popups_update()
	for _p in all(popups) do
		if _p.fade < 1 then
			_p.y = lerp(_p.y,_p.sy-8,0.125)
			_p.fade += 1/15
			if _p.fade >= 1 then
				del(popups,_p)
			end
		end
	end
end

function popups_draw()
	local lx = camx/2
	local ly = camy/2
	for _p in all(popups) do
		if(_p.fade >= 0.5) fillp(▒)
		if(_p.fade >= 0.75) fillp(░)
		for i=-1,1 do
			for j=-1,1 do
				print(_p.txt,lx+_p.x+i-#(_p.txt)*2,ly+_p.y+j,0)
			end
		end
		print(_p.txt,lx+_p.x-#(_p.txt)*2,ly+_p.y,7)
		fillp(█)
	end
end
__gfx__
33333333333333222222233333333333333333322222222233333330001111aaaaaa000111aaaaaabbbbbbbbbbb444bb22244442bbbbbbbbbbb0000005500000
33333333332222eeeee28033333333333333322eeeeeee28033333300655551111aa006555111aaabbbbbbbbb442bbb244444ff2bbbbbbbbbbb0000056655000
3333333332eeeeeeee28880333333333333332eeeeeee2888033333116550000551a11655000511abbbbbbbbb24bb22444f4fff22bbbbbbbbbb0000056666500
333333332eeeee1eee2888033333333333332eeee6eee28880333331165051110651116505110651bbbbbbbbbb2224444ffff42442222bbb2bb0055555666650
333333330000e16ee28888803333333333330cee16ee288888033331165055111051116505511051bbbbbbbbb224444444224444244444b42bb0056666666665
33333331066606cee288888033333333333066606cee288888033331165016611051116501611051bbbbbbbb244444482d82444444422242bbb0056666666665
3333333166c666cce20888803333333333166c666c0e208888033331165500111651115500011651bbbbbbb244442228dd8d2244442bbb2bbbb0056666666665
33333316ccccc6cc1088880720003333316cc0cc6cce088888220001165550006551115555006551bbbbbbb24442dd08228024444442bbbbbbb0056666666665
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771cc1165000055551115500055551bbbbbbb24440ddd8208d444444442bbbbbb0055555666650
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f0101150111106551115011106551bbbbbb2474440dde20e0444444442bbbbbb0000056666500
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf223331150511110551115051110551bbbbbb247744d00e00e044444442222bbbb0000056655000
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333005056611051a11505611051abbbbbbb47064888e81e88444444444422220000005500000
306dd03112f774777f772723333300dd00012f774777f7722333333005000111051a11500011051abbbbbb244d044d7e77e622444444444442b0000055550000
01d16d2332777f77f772772333330d0d16022777f77f77276233333001101111651a00100110651abbbbbb4449da4d780887624444444442bbb0000566665000
01d0dd7232f777ff722267623333301610722f777ff72267723333300011000011aa0001000111aabbbbb244494a4078708724444444442bbbb0005666666500
010d602722222228866627723333330007273222228866667723333bbbbbbbb42bbb222222bbbbbbbbbbb444494a47d8008244444444422bbbb0056666666650
30160072222266e77e670ff23333332f772f26666e66e7202223333bbbbbb44bbb224444f2bbbbbbbbbbbb2444a42978d011244444444442bbb0056666666650
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333bbbbb424b2244444ff222bbbbbbbbbbb244421009aa0012444424444422b0566666666665
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333bbbbb22b22444f44f424222bbbbbbbbb20244210002800024442222422220566566665665
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333bbbbbb224444444444442242bbbbbbbb21124421111888800222bb22bbbb0055566665550
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333bbbb222444442224444424442222bbbbb11022111110888000bbbbbbbbbb0000566665000
333333333333333333333333333333333222eeef00102f1cc123333bbb244444422dd2224444424442bbbbbb011111110100220110bbbbbbbbb0000566665000
33333326767e2e88128ee11282333333333267ee2f212feeee23333bbb2442dddddddd22444444224bbbbbbbb01100000002200111bbbbbbbbb0000555555000
333332ed7d8288828286666d2333333333333333222222233333333bbb24442d008228244444442b2bbbbbbbb0010200000880b010bbbbbbbbbeee1111eeeeee
33332eee2228222228877d2d7e23333333333222eeeee2803333333bb247444dd08208d24444442bbbbbbbbbb0002221111880791bbbbbbbbbbee11ccc111eee
3333288e8882d6d62287e888e872333333332eeeeeee28880333333b2447744d00e20e044444442bbbbbbbbb01122bb0110280d79bbbbbbbbbbe1c1cccc1c1ee
33333277676dd00222ee8888276233333332eeee1eee28880333333bb247064288e80e88444442bbbbbbbbbb111bbb00110080867dbbbbbbbbb1ccc1ccc1c1ee
33333322222003333067777766233333333100e16ee288888033333bb244d024d0e0de022444442222bbbbbb011bb0111180802060bbbbbbbbb11cc11111c1ee
33333333333333333302222222333333330c6606cee288008033333b2444dd24d77778762444444442bbbbbb0110001110888800dbbbbbbbbbbe1c11c1c11111
33333333333332222333333333333333331c6666cce280088022333b244494a20708876244444444442bbbbbb0100000088828800bbbbbbbbbbe11c1c11cc1c1
3333333333332eeee223333333333333316c06c6cce2808802f20c0b244494a2d0070704444444444442bbbba00a228888282880bbbbbbbbbbbe1e1cccc1c11e
3333333333000eeeeee2233333333333316cc0cccc66000007721c12444494a0977081104444444422242bbb9aaa08888882282bbbbbbbbbbbbeeee1111111ee
33333333316660eee1eee223333333331611cc00c6601f6c61f2033b24449a2009aa00000444444242b24bbb99aa02888880001bbbbbbbbbbbbbbbbbbbbbbbbb
333333331660c60061eeeee2333333331131cc100112f4f61c13333bb2444221000088880044444442bb2bb000995728800d007bbbbbbbbbbbbbbbbbbbbbbbbb
333333316cc0cc60c0eee228033333333316c0fff2f0727ff233333bb211124211110888811022444422bbbb0ddd700000d7000bbbbbbbbbbbbbbbbbbbbbbbbb
333333311c6c0cc6c0e2288803333333331612727070277f2233333bb20124211101108220111b2222222bbbb6671101006700bbbbbbbbbbbbbbbbbbbbbbbbbb
3333333316cc0cc6cc2888888033333332212f77007777726623333bbb2111111100100200111bbbbbbbbbbbb007d0d0000000bbbbbbbbbbbbbbbbbbbbbbbbbb
33333331111101cccc880088803333224ff22000772277266623333bbbb01110000000280b00bbbbbbbbbbbbbb0d0d0d000110bbbbbbbbbbbbbbbbbbbbbbbbbb
33333331322ff01616000888803332f777710d6107f882622233333bbbb00112000000880000bbbbbbbbbbbbbb00d0d0000010bbbbbbbbbbbbbbbbbbbbbbbbbb
333333332ffff06f0008888880332777f770661d60222684ff43333bbbbb0002201110880790bbbbbbbeee000eeeeeeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
333333332777f4200f161180023327474720dd06007e77e07773333bbbb01102bb1110287779bbbbbbbee088000eeeeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333330007777f4f416cc17f2332f4f222011d0d0000011c711333bbbb110bbbb0118086076bbbbbbbee000888000eebbbbbbbbbbbbbbbbbbb44bbbbbbbbbbb
3333330d0d07f777227f1c7771133222ff21011110111c2cccc1333bbbb111bb0111180820d0bbbbbbb000888888880ebbbbbbbbbbbbbbbbbb4b24bbbbbbbbbb
33333010dd107ff22874242f21cc333333333333333333333333333bbbb111b00111088882d0bbbbbbb088888080880ebbbbbbbbb242bbbbbb2bb4bbbbbbbbbb
3333306d0160227728f23222301c3333333333333332222233333333bbb0110000028288880bbbbbbbb088800000000ebbbbbbbbb444442bbbbbb244bbbbbbbb
32220011d6d06622222333333300333333333333222eeee203333333bbb900a02888882288bbbbbbbbbe0800008000eebbbbbbbbbff444442b2bbbb2bbbbbbbb
32ff7006dd068866666233333333333333333222eeeee82880333333bbba9aa28888882880bbbbbbbbbe08800780700ebbbbbbbb2ff244f44242bb2bbbbbbbbb
32f77f00002e7686266623333333333333332eeeeeeee28888033333bbb9aa92228880d00dbbbbbbbbb0088800800880bbbbbbbb4fffffff44442222bbbbbbbb
2f77472f266eee76222623333333333333332eeee6ee828088033333bb0d99920222007000bbbbbbbbb0808007880880bbbbbbb2444ff24f44444444442bbbbb
2ff772ff276777772ff22333333333333333000e16ee280888803333bb0fd1d7000070700bbbbbbbbbb080807070000ebbbbbbb4444444444444444442bbbbbb
2f747f22e20007772ff2333333333333333066600c1e200888823333bbb0f0701d0700000bbbbbbbbbbe000000000eeebbbbbb24444444444422444444442bbb
2f7722eeee2000cc177f133333333333333160c60cc18088882f0011bbbbd07d0d1000000bbbbaaaaaaaaaaaa22aaaaaaaaaa2444444dd242ddd444442bbbbbb
3222328eeee0e111cf777133333333333316c0ccc6c10200007721c1bbbbb071d0d0b0000bbbbaaaaaaaaaaaaa222aaaaaaaa24444442dddd8d024474442bbbb
333326767e2e80811177f113333333333316cc0c11c6006c110f2333bbbbbb0dd1d0b000bbbbbaaaaaaaa222222442aaaaaaa244444dd8ddd820027744442bbb
3332ed7d82888de8611111133333333333111c100f6200f6f1142333bbbbbbbbbbbbbbbbbbbbbaaaaaa244444222222aaaaaa2444442082228dd400d44442bbb
3333333333322222333333333333333333336c1200ff0f4ff2223333bbbbb00000bbb001bbbbbaaa2aa44444444444442aaaa2444444d8222e0088d294444bbb
33333333322eeeee222233333333333333316132f0274727f2333333bbbbb0010bbbb000bbbbbaa2aa24f444444444f442aaa224444410e02e8840a2944442bb
3333333322eeeeeeee282333333333333331132f7477f88723333333bbbbb0011bbbb001bbbbbaa2a22fffffff4f4fff44aaabb2444420e08ee040a29444422b
33333333000ee1eee2888033333333333223330007f2887262333333bbbb00010bbbb011bbbbba24244444f4f4ff4444442aabb2224228ee77e7240922244bbb
333333316660066e28888033333333322ff210d11022222672333333bbbb0011bbbbb010bbbbba244424444444444444444aabb20008807e880da000112222bb
3333331066660c1e2888880333333327777d0d61600e762222333333bbbb0110bbbbb110bbbbbaa22244444244444444444aabb051010008070d0a041102222b
33333160cccc6c028880880333333277f47100060d0770ff03333333bbbb0000bbbb00010bbbbaaa2422e2224e244444424aabb00010011000d08a0001122222
3333311c0ccccc02800888033333324ff4f601ddd10cc17721333333bbb00100bbb000000bbbbaaa2222002ee20224ee442aabb0d10d071022288a4401102222
333333160011c66808888822333332f4f2ff201110cc1c1772133333bbb00100bbb00b000bbbbaa22242e00eee02e22e222aabb000dd00000220a8000111000b
3333316c100f61f0000882f233333322222f2800002f1cc111133333bb0010b0bbbb0b0000bbbaa2242ff44eff4f4422222aabb20000776009aa882100111bbb
333331112f0f1f0016c00771c13333326f22e2e8222ee1cc11333333bb0010b0bbbb0bb0000bbaa2442fffffffff222242aaabbb1116070122282281bb0000bb
333331332747f20ff11cf2f01c03332ed7d828882ee8766d82333333b0000bbbbbbbbbbbbbbbb2aa240fff2082ff24244aa22bb011d0670188800200bbb1110b
33333332f777774777f04223300332eee7222222d2877227e2333333b000bbbbbbbbbbbbbbbbb22244400ff88ff2242442242bb1111000612222d00bbbb000bb
3333333277f7777277f222333333268e888820062287e888e2233333000bbbbbbbbbbbbbbbbbba24444e2880042e42444442abb119a00d0820288dd00b990bbb
33333333277fff882f27233333332767662033302ee8888826233333bbbbbbbbbbbbbbbbbbbbba224444288224ef2444442aab1189aa010020888d0770a99bbb
33332233020002282266723333332222222333306228888762333333bbbbbbbbbbbbbbbbbbbbba224440222224ff24444442ab12899aa1d200200d67000abbbb
3222ff21001608622622223333333333333333330667676623333333bbbbbbbbbbbbbbbbbbbbbaa244200000244f24444442ab122299908000ddd0d06760bbbb
32f777100d60d0ee7727703333333333333333333222222233333333bbbbbbbbbbbbbbbbbbbbbaaa422effff000fe244442aa100022000bb051d7000d000bbbb
3277471010dd1000001c71133333bbbbbbbbbbbbbbbbb44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaa2ef2fffffffe2fffe22aaa0011001bbbbbbb0700000100bbb
2f4f4f000111d011ccc11c113333bbbbbbbbbbbbbbbb4b24bbbbbbbbbbbbbbbbbbbbbbbbbbbbb44bbbb2442bb22bbbbbbbbbb000110100bbb000000001100bbb
2ff42ff00101000112f1cc123333bbbbbbbbbbbbbbbb2bb4bbbbbbbbbbbbbbbbbbbbbbbbbbbb4bb2bb24ffbbb272bbbbbbbbb011001000bb000000000001bbbb
22222f008000f8112feeee233333bbbbbbbbbbbbbbbbbbb444bbbbbbbbbbbbbbbbbbbbbbbbbb4bbbb24fff42027200bbbbbbb010001000bb0b00000000bbbbbb
bbbbbbbbbbbbbbbbbbb44bbbbbbbbbbbbbbb22222bbbbbb2bb4bbbbbbbbbbbbbbbbbbbbbbb444b2444ff444422821022bbbbbb101100b0bbb0000bbbbbbbbbbb
bbbbbbbbbbbbbbbbbb422bbbbbbbbbbbbbbb2444422b22bbbb2bbbbbbbbbbbbbbbbbbbbbbb4bb244fff444227722022bbbbbbbbb0000bbbbb00000bbbbbbbbbb
bbbbbbbbbbbbbbbbb42b2bbbb2222bbbbbbb2f4444444442b2bbbbbbbbbbbbbbbbbbbbbbbb2244444444427772d294bbbbbbbbb00000bbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb4bbbbb2444f2bbbbbbb2ff44ff4444422222222bbbbbbbbbbbbbbbbbbb2444224d442dd2d220abbbbaaaaaaaaaaaa2222aaaaaaaaaaaaaa
bbbbbbbbbbbbbbbbb2bbb24444ff2bbbbbbb2fffff4f44444444444222bbbbbbbbbbbbbbb244444d22244220d220dabbbbaaaaaaaaaaaaa242222aaaaaaaaaaa
bbbbbbbbbbbbbbb42bb2244f44f4f2bbbbbb2f44f44444444444442bbbbbbbbbbbbbbbbb2444444ddd82220100000abbbbaaaaaaaaa222222444442aaaaaaaaa
bbbbbbbbbbbbbb4bbb2444ff4f44442bbbbb2444444442dd244444442bbbbbbbbbbbbbb24444442dd22e00101011a22bbbaaaaaaa24444444444f442aaaaaaaa
bbbbbbbbbbbbbb2bb444444444444242bb2bb2442dddd8ddd4474444422bbbbbbbbbbbbb44442dd8222e010d049910422baaaaaa244444444f44f444aaaaaaaa
bbbbbbbbbbbbbbb24444442d24444444222bb24442ddd8ddd4764444442bb22bbbbbbbb24442dd2de220e05d0411104422aaaaaa4ff44ff44fff44442aaaaaaa
bbbbbbbbbbbbb244444442dd42444424442b2442dd8d22edd280944444422422bbbbbb244442dddded287e04401104422baaa2aa4444f4f4f44444442aaaaaaa
bbbbbbbbbbbb244442ddd22d2244444222bb4444428222e088ad9444444442bbbbbbbb24444442100e807e04011144442baaa2a224444444444444442aaaaaaa
bbbbbbbbbbbb24444dd0022224444442bbbb44444dde020ed0ad294444222bbbbbbbbbb2444442ddde06d08111104442bbaaa44244444444444444422aaaaaaa
bbbbbbbbbbbbb44442dd802042444442bbbb4244442ed08e70a049010442bbbbbbbbbbb2442dd42087e02011000042222baaa24242224442ee244ee42aaaaaaa
bbbbbbbbbbb244774ddde20084444442bbbb4244442de80d800a922110442bb2bbbbbbb44442d008068d011100022222bbaaaa22222e24e220e22fe2422aaaaa
bbbbbbbbbbb224788888e88de844442b222b2b4444486e008d0a220001044222bbbb8b2444442dda40d877100022222bbbaaaaa2222e00ee402e2f2222aaaaaa
bbbbbbbbbbbb446d02dded08e4444444442bbb2444866789d81002080104442bbbb80bb244444940a0dd6a000000bbbbbbaaaaa2242ee0eff4f422224aaaaaaa
bbbbbbbbbbb2444dd20080078244444442bbbbb4444420806700a088001222bbbb07bbbbb44449e4a990aa80881bbbbbbbaaaaa2442ef4fffff4424442a2aaaa
bbbbbbbbbbb444420011000dd24444444442bbb244222298007a000880101bba977bbbbbb224429920999888880bbbbbbbaaaaaa42efff2082f224444442aaaa
bbbbbbbbbb2442011111000722244444442bbbb000022901100a0828000011aa9d08bbbbbb22222144440108220bbbbbbbaaaaaa40effff88ff42444442aaaaa
bbbbbbbbbbb221111110d0822000244442bbbb010600291111a00022000001aa900bbbbbbb2222111140111020bbbbbbbbaaa2a444002222222ef244442aaaaa
bbbbbbbbbbbb11111110a11201150244422bbb00101021aaaa10022800b000aa907bbbbbbb2220111101000220bbbbbbbbaaa22444442888884ffe444442aaaa
bbbbbbbbbbbb100111101a12d10112224444bb51100001111110088820bbbbaa9000bbbbbbb220111111000281bbbbbbbbaaa244444e02222224ff444442aaaa
bbbbbbbbbbb0010011191a125010002222bbbb00dd0002811001028881bbbbb99bb88bbbbbbb00011000001881bbbbbbbbaaaa24444e00000222ff444422aaaa
bbbbbbbbbbb1000011099912000d0bbbbbbbbbb0000707210b011082810bbbbbbbbbbbbbbbbb00010b001108280bbbbbbbaaaaa444e2efff4400ef2442aaaaaa
bbbbbbbbbb01100001088020d000bbbbbbbbbbbbb0777000bbb01080810bbbbbbbbbbbbbbbbbb011bbdd61180880bbbbbbaaaaa24ff2fffffffe0ffe22aaaaaa
bbbbbbbb00111000112220260770bbbbbbbbbbbbbd700700bb010880881bbbbbbbbbbbbbbbbbb011b0d776080828bbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
bbbbbb011111101010220090d070bbbbbbbbbbbbb0dd7060b0108888880bbbbbbbbbbbbbbbbbb119ad7001088828bbbbbbaaa111ef42ef222eff0ef22f211aaa
bbbbb0228000080111101990d760bbbbbbbbbbbbbb0dd60800288888800bbbbbbbbbbbbbbbbb011a0d0010828820bbbbbba11555552ef2fff2ee46666555511a
bbbb02888888888110bb090d060bbbbbbbbbbbbbb0100d8b02828888028bbbbbbbbbbbbbbbb0119ad6002888220bbbbbbba1055622fff2fee22111110665051a
bbb028888088800110bb000d0d0bbbbbbbbbbbbbb10aa00b22882888828bbbbbbbbbbbbbbbb0009a10288888000bbbbbbb150122ffff22ffe211111666060151
bbb22288880000a0090bba900dd0bbbbbbbbbbbbb099aa9b22882888280bbbbbbbbbbbbbbbbb009a02888880d00bbbbbbb156288822222eff000166611106551
bbb022288202209aaa0bba0000d2bbbbbbbbbbbbbb199900d02200d00000bbbbbbbbbbbbbbbbbb9902888807d0bbbbbbbb0560228820202ef255611111106550
bbbd022822222009a00bbbaaab002bbbbbbbbbbbbbb010b7d00ddd0ddd000bbbbbbbbbbbbbbbbbbb02220077ddbbbbbbbb05611122111022fe22011111116150
bbb7d0222000d0900a0bbbbbbbbbbbbbbbbbbbbbbbbbbbb700dddbb777600bbbbbbbbbbbbbbbbbbbbdd6006000bbbbbbbb55611111111022ff82011111116155
bbbd6d0000dddd099a0bbbbbbbbbbbbbbbbbbbbbbbbbbb170076bbb076610bbbbbbbbbbbbbbbbbbbbb66000100bbbbbbbb556011111111028f82111111106155
bbb07600600dd660770bbbbbbbbbbbbbbbbbbbbbbbbbbb000050bbbb000010bbbbbbbbbbbbbbbbbbbb0001110bbbbbbbbb556011111100002882001111106155
bbb000000bbb000d600bbbbbbbbbbbbbbbbbbbbbbbbbbb00111bbbbbb00001bbbbbbbbbbbbbbbbbbbbb000010bbbbbbbbb555601110000000222000011061555
bbb000000bbbb00dd60bbbbbbbbbbbbbbbbbbbbbbbbbb100100bbbbbb000100bbbbbbbbbbbbbbbbbbbbb000100bbbbbbbb555566600000000000000006615555
bbbb01100bbbbb00d08bbbbbbbbbbbbbbbbbbbbbbbbbb00110bbbbbbbb00010bbbbbbbbbbbbbbbbbbbbb000110bbbbbbbb555551166666666666666661555555
bbb00110bbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbb00010bbbbbbbbbbbbbbbbbbb0000010bbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
bb000000bbbbbb00100bbbbbbbbbbbbbbbbbbbbbbbbbb0010bbbbbbbbbbb0010bbbbbbbbbbbbbbbbbbb000010bbbbbbbbb555555666666666110000066555555
bb001110bbbbbbb00110bbbbbbbbbbbbbbbbbbbbbbbb00010bbbbbbbbbbbb0110bbbbbbbbbbbbbbbbb001100bbbbbbbbbb555566000000000111111660665555
bb00110bbbbbbbbb00010bbbbbbbbbbbbbbbbbbbbbbb00110bbbbbbbbbbbb00010bbbbbbbbbbbbbbbb001000bbbbbbbbbb555601166611111111116611006555
b00110bbbbbbbbbbb0010bbbbbbbbbbbbbbbbbbbbbbb01000bbbbbbbbbbbb000010bbbbbbbbbbbbb00011010bbbbbbbbbb556011111661111000161111106555
00100bbbbbbbbbbbbb0100bbbbbbbbbbbbbbbbbbbbb01000bbbbbbbbbbbbbb0b1110bbbbbbbbbb0001000100bbbbbbbbbb050111111116600555011111116550
1100bbbbbbbbbbbbbb00100bbbbbbbbbbbbbbbbbbbb01000bbbbbbbbbbbbbb0b00000bbbbbbbb00001000010bbbbbbbbbb010111111111055555011111116110
010bbbbbbbbbbbbbbb0b0010bbbbbbbbbbbbbbbbbb0010b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0b001000110bbbbbbbbbb010111111111055555011111106110
010bbbbbbbbbbbbbbbbb00000bbbbbbbbbbbbbbbbb0100b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb001b00010bbbbbbbbbb016011111100000000111111106110
000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0011b0b000bbbbbbbbbb015601100000000000000011065110
1000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0010b0b0000bbbbbbbbba0156600000000000000000665110a
00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbb0000bbbbbbbbba0115566666000000000666551110a
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111191919191919111111111111111111111111111111
11111111155111111111155555511111111155551111111111551111111111111111111111115511111111915555559191911115555111111111155111111111
11111115566511111111156666511111111566665111111115665511111111111111111111556651111119195666659919191156666511111111566551111111
11111156666511111111156666511111115666666511111115666651111111111111111115666651111111915666659991911566666651111111566665111111
11111566665555511115556666555111156666666651115555566665111111111111111156666555551119555666655599195666666665111555556666511111
11115666666666511156656666566511156666666651115666666666511111111111111566666666651195665666656659915666666665111566666666651111
11115666666666511156666666666511566666666665115666666666511111111111111566666666651115666666666659156666666666511566666666651111
11115666666666511115666666665111566566665665115666666666511111111111111566666666651191566666666599956656666566511566666666651111
11115666666666511115666666665111155566665551115666666666511111111111111566666666651119566666666599195556666555111566666666651111
11111566665555511111566666651111111566665111115555566665111111111111111156666555551111956666665991911156666511111555556666511111
11111156666511111111156666511111111566665111111115666651111111111111111115666651111119195666659919191156666511111111566665111111
11111115566511111111115555111111111555555111111115665511111111111111111111556651111111919555599191911155555511111111566551111111
11111111155111111111111111111111111111111111111111551111111111111111111111115511111111191919191919111111111111111111155111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111222211111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111124222211111111111111111111111111111111111111111111111111111111111
11111111111222222222222222222222222222222222222222222222222222222444442222222222222222222222222222222222222222222222111111111111
11111111111111111111111111111111111111111111111111111111124444444444f44211111111111111111111111111111111111111111111111111111111
22222222222222222224442222244442222222222222222222222222244444444f44f44422222222222222222222222222222222222222222222222222222222
11111111111111111442111244444ff21111111111111111111111114ff44ff44fff444421111111111111111111111111111111111111111111111111111111
22222222222222222242222444f4fff22222222222222222222222224444f4f4f444444422222222222222222222222222222222222222222222222222222222
1111111111111111112224444ffff424422221112111111111111212244444444444444421111111111111111111111111111111111111111111111111111111
22222222222222222224444444224444244444242222222222222442444444444444444222222222222222222222222222222222222222222222222222222222
1111111111111111244444482d82444444422242111111111111124242224442ee244ee421111111111111111111111111111111111111111111111111111111
222222222222222244442228dd8d2244442222222222222222222222222e24e220e22fe242222222222222222222222222222222222222222222222222222222
11111111111111124442dd0822802444444211111111111111111112222e00ee402e2f2222111111111111111111111111111111111111111111111111111111
22222222222222224440ddd8208d4444444422222222222222222222242ee0eff4f4222242222222222222222222222222222222222222222222222222222222
111111111111112474440dde20e04444444421111111111111111112442ef4fffff4424442121111111111111111111111111111111111111111111111111111
22222222222222247744d00e00e0444444422222222222222222222242efff2082f2244444422222222222222222222222222222222222222222222222222222
11111111111111147064888e81e8844444444442222111111111111140effff88ff4244444211111111111111111111111111111111111111111111111111111
22222222222222244d044d7e77e6224444444444422222222222222444002222222ef24444222222222222222222222222222222222222222222222222222222
111111111111114449da4d780887624444444442111111111111122444442888884ffe4444421111111111111111111111111111111111111111111111111111
2222222222222244494a407870872444444444222222222222222244444e02222224ff4444422222222222222222222222222222222222222222222222222222
1111111111111444494a47d800824444444442211111111111111124444e00000222ff4444221111111111111111111111111111111111111111111111111111
222222222222222444a42978d011244444444442222222222222222444e2efff4400ef2442222222222222222222222222222222222222222222222222222222
111111111111111244421009aa0012444424444422222222222222224ff2fffffffe0ffe22222222222222222222221111111111111111111111111111111111
22222222222222220244210002800024442222422222222222222111ef42ef222eff0ef22f211222222222222222222222222222222222222222222222222222
22222222222222221124421111888800222222222222222222211555552ef2fff2ee466665555112222222222222222222222222222222222222222222222222
2222222222222222110221111108880002222222222222222221055622fff2fee221111106650512222222222222222222222222222222222222222222222222
22222222222222220111111101002201102222222222222222150122ffff22ffe211111666060151222222222222222222222222222222222222222222222222
22222222222222222011000000022001112222222222222222156288822222eff000166611106551222222222222222222222222222222222222222222222222
222222222222222220010200000880201022222222222222220560228820202ef255611111106550222222222222222222222222222222222222222222222222
2222222222222222200022211118807912222222222222222205611122111022fe22011111116150222222222222222222eeeeeee28022222222222222222222
222222222222222201122220110280d792222222222222222255611111111022ff8201111111615522222222222222222eeeeeee288802222222222222222222
222222222222222211122200110080867d2222222222222222556011111111028f821111111061552222222222222222eeee6eee288802222222222222222222
222222222222222201122011118080206022222222221110005560111111000028820011111061500011122222222220cee16ee2888880222222222222222222
22222222222222220110001110888800d2222222211155560055560111000000022200001106155006555111222222066606cee2888880222222222222222222
222222222222222220100000088828800222222115000556115555666000000000000000066155511655000511222166c666c0e2088880222222222222222222
2222222222222222a00a22888828288022222215601150561155555116666666666666666155555116505110651216cc0cc6cce0888882200022222222222222
22222222222222229aaa08888882282ddddddd15011550561155555566000001111000006655555116505511051d16cc0ccccc6000080771cc22222222222222
222222222222222299aa02888880001ddddddd150116105611555566066111111111111660665551165016110000d116c01fff0f6cc1f2f01022222222222222
22222222222dddd000995728800d007ddddddd15611000551155560011661111111111661100655115500011016d0d6c1f0ff20ff11cf22ddddd222222222222
2222dddddddddddd0ddd700000d7000ddddddd15555000551155560111116100000016111110655115555000dd16d0c12ff02f47fff222ddddddddddddd22222
ddddddddddddddddd6671101006700d5d5d5d5155601110511055611111110555555011111116551155000500dd00012f774777f7722dddddddddddddddddddd
ddddddddddddddddd007d0d00000005d5d5d5d15501115051101161111111055555501111111611115011100d0d16022777f77f772762ddddddddddddddddddd
ddddddddddd5d5d5d50d0d0d000110d5d5d5d5d150116505110116011111105555550111111061111505111001610722f777ff72267725d5d5d5dddddddddddd
dddd5d5d5d5d5d5d5d00d0d00000105d5d5d5d515011000511011601111111000000111111106111150561105000727d222228866667725d5d5d5d5d5d5ddddd
d5d5d5d5d5d5d5d5d5d00000d5d001555555555156011001000115601100000000000000110651111500011052f772f26666e66e720222d5d5d5d5d5d5d5d5d5
5d5d5d5d5d5d5d5d5d5001055550005555555555111000100050115660000000000000000665110001001106527777726077e7ee72ff4d5d5d5d5d5d5d5d5d5d
d5d5d5d5d5d5555555500115555001555555555555555555555011155666000000000066655111000010001112ff7740cc077ee702fff5555555d5d5d5d5d5d5
5d5d555555555555550001055550115555555555555555555555555555555555555555555555555555555555552fff771110111cc177fc5555555555555d5d5d
555555555555555555001155555010555555555555555555555555555555555555555555555555555555555555224fffff2111cccc1111555555555555555555
55555555555555555501105555511055555555555555555555555555555555555555555555555555555555555555222eeef00102f1cc12555555555555555555
5555555555555555550000555500010555555555555555555555555555555555555555555555555555555555555555267ee2f212feeee2555555555555555555
555555555555555550010055500000055555555555555555555555555555555555555555555555555555555555526767e2e88128ee1128255555555555555555
5555555555555555500100555005000555555555555555555555555555555555555555555555555555555555552ed7d8288828286666d2555555555555555555
555555555555555500105055550500005555555555555555555555555555555555555555555555555555555552eee2228222228877d2d7e25555555555555555
55555555555555550010505555055000055555555555555555555555555555555555555555555555555555555288e8882d6d62287e888e872555555555555555
555555555555555000055555555555555555555555555555555555555555555555555555555555555555555555277676dd00222ee88882762555555555555555
55555555555555500055555555555555555555555555555555555555555555555555555555555555555555555552222200555506777776625555555555555555
55555555555555000555555555555555555555555555555555555555555555555555555555555555555555555555555555555550222222255555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555500000005555555555511115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555000808888005552333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550800088888805588bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550880000800805588b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555000008000055588b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555080070870805588bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550088000800880588bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
5555555080888888000052333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550000000000555555555551111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__sfx__
2d0200200035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
910a00000080000800178001780023650236551780017800008000080017800178002365023655178001780000800008001780017800236502365517800178000080000800236000000023655236552365023650
2d040000180730c070003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350
010a000817f7017f700c6100000017f7017f700c610000030c600000000c600000000c6000000311600000030c000000000c600000000c600000000c000000000c600000000c000000000c600000000560000003
910a00000b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b610
010100200055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550
010400000c07300073000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070
510a00002f5502f5502f555245002f5502f5502f555245002f55032550345503655036550365552f5502f5502f555245002f5502f5502f555245002f5502f55032550325502f5502f55031550315502f5502f550
510a00002f5502f5502f555245002f5502f5502f555245002f55032550345503655036550365552f5502f5502f555245002f5502f5502f555245002f5502f55032550325502f5502f55034550325502d5502d550
910a01090080000800178701787023650236551787017870178000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800
910a00002f6002f6002f6002f600005001e5000c5001c500185001e5001850018500185001e50018500185002f6202f6202f6102f6102f6202f6202f6102f6102f6202f6202f6102f6102f6202f6202f6102f610
010a000017f7017f700c6100000017f7017f700c6100000317f7017f700c6100000017f7017f700c6100000317f7017f700c6100000017f7017f700c6100000317f7017f700c610000000b0730b07317f7019f70
4d0a00002f7502f7502f755247002f7502f7502f755247002f75032750347503675036750367552f7502f7502f755247002f7502f7502f755247002f7502f75032750327502f7502f75031750317502f7502f750
4d0a00002f7502f7502f755247002f7502f7502f755247002f75032750347503675036750367552f7502f7502f755247002f7502f7502f755247002f7502f75032750327502f7502f75034750327502d7502d750
010a00000b0730050000500005000b0731e5000c5001c5000b0730050000500005000b0731e5000c5001c5000b0730050000500005000b0731e5000c5001c5000b0730050000500005000b0731e5000c5001c500
510a00003255032550325503255032550325503255032550325403254032540325453255032555325503455034550345503455034550345503455037550395503955039550375503755037550375503655036550
510a00003655036550375503655034550345503455034550365503655036550365503255032550325503255034550345503255031555315503155032550325503455034550375503755036550365503455034550
910a00000b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6400b6300b6300b6300b6300b6300b6300b6300b6300b6200b6200b6200b6200b6200b6200b6200b620
910a000417650176300b6200b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b6000b600
010a00000b0530050000500005000b0531e5000c5001c5000b0530050000500005000b0531e5000c5001c5000b053005000b053005000b0531e5000b0531c5000b053005000b0530050017653176551765317653
4d0a00003275032750327503275032750327503275032750327403274032740327453275032755327503475034750347503475034750347503475037750397503975039750377503775037750377503675036750
010a000017000005000050000500170001e5000c5001c50017000005000050000500170001e5000c5001c50017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f7017f70
91280001236132f6002300000500170001e5000c5001c50023000005000050000500230001e5000c5001c50023000005000050000500230001e5000c5001c50023000005000050000500230001e5000c5001c500
910a00080080000800178001780023650236551780017800008000080017800178002360023600178001780000800008001580015800236002360015800158000080000800158001580023600236001580015800
4d0a00003675036750377503675034750347503475034750367503675036750367503275032750327503275034750347503275031755317503175032750327503475034750377503775036750367503475034750
910a00000b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b6200b620
910a00000b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b6100b610
910a00000080000800178701787023650236551787017870008000080017870178702365023655178701787000800008001587015870236502365515870158700080000800158701587023650236551587015870
910a000000800008001c8701c87023650236551c8701c87000800008001c8701c87023650236551c8701c87000800008001a8701a87023650236551a8701a87000800008001a8701a87023650236551a8701a870
510a00002d5502f550315503255032550325502f5502f55036550365503650036550365502f5003455034550345503455032550325503155031550325503255034550345502f50034550345502f5002d5502d550
510a00002d5002d5502f550315503255032550325502f550365503655036500365503655000000395503955039550395503755000000365500000034550000003255034500365503455032550325503155031550
4d0a00002d7502f750317503275032750327502f7502f75036750367503670036750367502f7003475034750347503475032750327503175031750327503275034750347502f70034750347502f7002d7502d750
4d0a00002d7002d7502f750317503275032750327502f750367503675036700367503675000700397503975039750397503775000700367500070034750007003275034700367503475032750327503175031750
4d0a00002f7502f7502f7502f7502f7502f7502f7502f750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d70a00002b6103a6103261028610226101f6101d6101961016610146101461015610186101a6101d610206102261024610286102c6102e6102e6102e6102f6102e6102f610316103261034610376103b6103b610
910a01090080000800178701787017800008001787017870178000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800
510a00002f5502f5502f5502f5502f5502f5502f5502f5502f5502f5502f5502f5552f5502f550315503155032550325503255032550315503155031550315502f5502f5502f5502f550315502f5502d5502d550
510a0000365503655034550345503255032550345503455032550325503155031550325503255031550315502f5502f55031550315502f5502f5502d5502d5502f5502f5502f5502f5502d5502d5502d5502d550
4d0a00002f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7552f7502f750317503175032750327503275032750317503175031750317502f7502f7502f7502f750317502f7502d7502d750
4d0a0000367503675034750347503275032750347503475032750327503175031750327503275031750317502f7502f75031750317502f7502f7502d7502d7502f7502f7502f7502f7502d7502d7502d7502d750
010a000017f7017f700c6100000017f7017f700c6100000017f7017f700c6100000017f7017f700c6100000017f700c61017f700c61017f700c61017f700c61017f700c61017f700c61017f700c61017f700c610
510a00003655036550375503655034550345503455034550365503655036550365503255032550325503255532550325503455034550325503255031550315502f5502f5502b5502b5502a5502a5502855028550
4d0a00003675036750377503675034750347503475034750367503675036750367503275032750327503275532750327503475034750327503275031750317502f7502f7502b7502b7502a7502a7502875028750
910a00000b6400b6400b6400b6400b6400b6400b6400b6400b6300b6300b6300b6300b6300b6300b6300b6300b6200b6200b6200b6200b6200b6200b6200b6200b6100b6100b6100b6100b6100b6100b6100b610
790a000017b7017b6017b600c00017b7017b6017b600c00317b7017b6017b600c00017b7017b6017b600c00315b7015b6015b600c00015b7015b6015b600c00315b7015b6015b600c00015b7015b6015b600c003
790a000010b7010b6010b600000010b7010b6010b600000310b7010b6010b600000010b7010b6010b60000030eb700eb600eb60000000eb700eb600eb60000030eb700eb600eb60000000eb700eb600eb6000003
790a000010b7010b6010b600000010b7010b6010b600000310b7010b6010b600000010b7010b6010b60000031cb531cb0028b5328b002fb5323b0021b5021b0021b5021b0021b5021b0021b5021b0021b500d600
090a00002857028570265702650025570255702857028570265702650025570255702857026570255702557028570285702657026500255702557028570285702657026500255702557028570265702557025570
090a00002857026570255702550028570265702557025500285702657025570255002857026570255702550028570265702557025500285702657025570255002857026570255702550028570265702557025500
4d0a00002877028770267702670025770257702877028770267702670025770257702877026770257702577028770287702677026700257702577028770287702677026700257702577028770267702577025770
4d0a00002877026770257702570028770267702577025700287702677025770257002877026770257702570028770267702577025700287702677025770257002877026770257702570028770267702577025700
510a00002f5502f55000000000002f5502f55000000000002f5502f550325503455036550365502f5502f55000000000002f5502f55000000000002f5502f5500000000000315503255034550345503455034550
510a00002f5502f55000000000002f5502f55000000000002f5502f55032550345503655036550395503955032550325502f5502f550325503255036550365503455034550315503255031550315502d5502d550
4d0a00002a7502a75000700007002a7502a75000700007002a7502a750327503475031750317502a7502a75000700007002a7502a75000700007002a7502a750007000070031750327502f7502f7502f7502f750
4d0a00002a7502a75000700007002a7502a75000700007002a7502a750327503475031750317502a7502a7502d7502d7502a7502a750347503475036750367502f7502f750377503775031750317502d7502d750
510a00002f5502f5502f5502f5502f5502f5502f5502f5502f5502f55500000000002f5502f550315503155032550325503255032550315503155031550315502f5502f5502f5502f550315502f5502d5502d550
510a0000365503655034550345503255032550345503455032550325503155031550325503255031550315502f5502f55031550315502f5502f5502d5502d5502f5502f5502f5502f5502d5502d5502d5502d550
510a00002f5502f5502f5502f5502a5502a5502a5502a550285502855028550285502a5502a5502a5502a5502d5502d5502d5502d5502b5502b5502b5502b5502a5502a5502a5502a55028550285502855028550
510a00002a5502a5502a5502a55026550265502655026550285502855028550285502655026550265502655036550365503655036550325503255032550325503455034550345503455031550315503155031550
4d0a00002f7502f7502f7502f7502f7502f7502f7502f7502f7502f75500700007002a7502a7502d7502d7502f7502f7502f7502f7502d7502d7502d7502d7502a7502a7502a7502a750317502f7502d7502d750
4d0a0000327503275031750317502f7502f7503175031750327503275031750317502f7502f75031750317502f7502f7502d7502d7502f7502f75028750287502f7502f7502f7502f7502d7502d7502d7502d750
4d0a00002f7502f7502f7502f7502f7502f7502f7502f7502f7502f75500700007002f7502f750317503175032750327503275032750317503175031750317502f7502f7502f7502f750317502f7502d7502d750
4d0a0000367503675034750347503275032750347503475032750327503175031750327503275031750317502f7502f7502d7502d7502f7502f75031750317503475034750347503475031750317503175031750
__music__
00 23424344
00 04240844
00 04240944
00 040a490d
00 0c0a0b0e
00 0f121044
00 0f051144
00 0f175a15
00 14175b19
00 041c521e
00 041d5b1f
00 041c5a20
00 041d5b21
00 041c5a25
00 041d5b26
00 041c5a27
00 291d1828
00 0f121044
00 0f532a44
00 0f175a15
00 14172b6c
00 2d133044
00 2e133144
00 2d131832
00 2f130233
00 041c121e
00 041d5b1f
00 041c5a20
00 041d5b21
00 041c383c
00 041d393d
00 041c3a3e
00 291d3b3f
00 040a347c
00 040a357c
00 040a3436
00 040a3537
00 0f121044
00 0f052a44
00 0f175a15
00 14172b6c
00 0f2c521e
00 0f455b1f
00 0f2c5a20
00 0f5d5b21
00 22424344

